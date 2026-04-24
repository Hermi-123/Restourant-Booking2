from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from . import models, schemas, database
from .database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Smart Restaurant API", description="AI-driven restaurant ordering system")

@app.get("/")
def read_root():
    return {"message": "Welcome to Smart Restaurant API"}

# Seed data endpoint (for testing)
@app.post("/seed")
def seed_data(db: Session = Depends(get_db)):
    # Check if data already exists
    if db.query(models.Category).first():
        return {"message": "Database already seeded"}
    
    # Categories
    categories = [
        models.Category(name="Appetizers"),
        models.Category(name="Main Course"),
        models.Category(name="Desserts"),
        models.Category(name="Beverages")
    ]
    db.add_all(categories)
    db.commit()
    
    # Tables
    tables = [
        models.Table(table_number=1, qr_code_id="TABLE1"),
        models.Table(table_number=2, qr_code_id="TABLE2"),
        models.Table(table_number=3, qr_code_id="TABLE3")
    ]
    db.add_all(tables)
    db.commit()
    
    # Menu Items
    menu_items = [
        models.MenuItem(name="Spring Rolls", description="Crispy veggie rolls", price=5.99, estimated_prep_time=10, category_id=1),
        models.MenuItem(name="Steak", description="Grilled ribeye", price=25.50, estimated_prep_time=25, category_id=2),
        models.MenuItem(name="Pasta Carbonara", description="Creamy pasta with bacon", price=14.99, estimated_prep_time=15, category_id=2),
        models.MenuItem(name="Tiramisu", description="Classic coffee cake", price=7.50, estimated_prep_time=5, category_id=3),
        models.MenuItem(name="Red Wine", description="House special", price=9.00, estimated_prep_time=2, category_id=4)
    ]
    db.add_all(menu_items)
    db.commit()
    
    return {"message": "Sample data seeded successfully"}

import uuid

# --- Table Session Management ---
@app.post("/session/start", response_model=schemas.TableSession)
def start_session(qr_code_id: str, db: Session = Depends(get_db)):
    table = db.query(models.Table).filter(models.Table.qr_code_id == qr_code_id).first()
    if not table:
        raise HTTPException(status_code=404, detail="Invalid QR Code")
    
    # Check for existing active session for this table
    existing_session = db.query(models.TableSession).filter(
        models.TableSession.table_id == table.id,
        models.TableSession.status == "active"
    ).first()
    
    if existing_session:
        return existing_session
    
    new_session = models.TableSession(
        session_token=str(uuid.uuid4()),
        table_id=table.id
    )
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    return new_session

# --- Menu Endpoints ---
@app.get("/menu/categories", response_model=List[schemas.Category])
def get_categories(db: Session = Depends(get_db)):
    return db.query(models.Category).all()

@app.get("/menu/items", response_model=List[schemas.MenuItem])
def get_menu_items(category_id: Optional[int] = None, db: Session = Depends(get_db)):
    query = db.query(models.MenuItem).filter(models.MenuItem.is_available == True)
    if category_id:
        query = query.filter(models.MenuItem.category_id == category_id)
    return query.all()

# --- Ordering System ---
@app.post("/orders", response_model=schemas.Order)
def place_order(order_data: schemas.OrderCreate, session_token: str, db: Session = Depends(get_db)):
    # Validate session
    table_session = db.query(models.TableSession).filter(
        models.TableSession.session_token == session_token,
        models.TableSession.status == "active"
    ).first()
    
    if not table_session:
        raise HTTPException(status_code=403, detail="Invalid or expired session")
    
    total_amount = 0
    order_items = []
    
    for item in order_data.items:
        menu_item = db.query(models.MenuItem).filter(models.MenuItem.id == item.menu_item_id).first()
        if not menu_item or not menu_item.is_available:
            raise HTTPException(status_code=400, detail=f"Item {item.menu_item_id} is not available")
        
        item_total = menu_item.price * item.quantity
        total_amount += item_total
        
        order_items.append(models.OrderItem(
            menu_item_id=item.menu_item_id,
            quantity=item.quantity,
            price_at_order=menu_item.price
        ))
        
        # Track preference for AI
        pref = db.query(models.UserPreference).filter(
            models.UserPreference.user_id == session_token, # Using session token as temp user id
            models.UserPreference.menu_item_id == item.menu_item_id
        ).first()
        if pref:
            pref.order_count += item.quantity
        else:
            db.add(models.UserPreference(
                user_id=session_token,
                menu_item_id=item.menu_item_id,
                order_count=item.quantity
            ))

    order_number = f"ORD-{uuid.uuid4().hex[:6].upper()}"
    new_order = models.Order(
        order_number=order_number,
        table_session_id=table_session.id,
        total_amount=total_amount,
        items=order_items
    )
    
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order

@app.get("/orders/track/{order_number}", response_model=schemas.Order)
def track_order(order_number: str, db: Session = Depends(get_db)):
    order = db.query(models.Order).filter(models.Order.order_number == order_number).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@app.get("/session/orders", response_model=List[schemas.Order])
def get_session_orders(session_token: str, db: Session = Depends(get_db)):
    table_session = db.query(models.TableSession).filter(
        models.TableSession.session_token == session_token
    ).first()
    if not table_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return db.query(models.Order).filter(models.Order.table_session_id == table_session.id).all()

# --- Staff Dashboard ---
@app.get("/staff/orders", response_model=List[schemas.Order])
def get_staff_orders(active_only: bool = True, db: Session = Depends(get_db)):
    query = db.query(models.Order)
    if active_only:
        query = query.filter(models.Order.status.in_([models.OrderStatus.RECEIVED, models.OrderStatus.COOKING, models.OrderStatus.READY]))
    return query.order_by(models.Order.created_at.desc()).all()

@app.patch("/staff/orders/{order_id}/status", response_model=schemas.Order)
def update_order_status(order_id: int, status: schemas.OrderStatus, db: Session = Depends(get_db)):
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order.status = status
    db.commit()
    db.refresh(order)
    return order

# --- AI Feature: Smart Recommendations & Upselling ---
@app.get("/ai/recommendations/{session_token}", response_model=List[schemas.MenuItem])
def get_recommendations(session_token: str, db: Session = Depends(get_db)):
    # 1. Get user preferences for this session
    user_prefs = db.query(models.UserPreference).filter(models.UserPreference.user_id == session_token).all()
    ordered_item_ids = [p.menu_item_id for p in user_prefs]
    
    # 2. Basic Personalization: Recommend items from categories the user hasn't tried yet but are popular
    # Or suggest pairings (Upselling)
    
    recommendations = []
    
    # Check if they have ordered a Main Course (category_id=2) but no Drink (category_id=4)
    has_main = any(db.query(models.MenuItem).filter(models.MenuItem.id == oid, models.MenuItem.category_id == 2).first() for oid in ordered_item_ids)
    has_drink = any(db.query(models.MenuItem).filter(models.MenuItem.id == oid, models.MenuItem.category_id == 4).first() for oid in ordered_item_ids)
    
    if has_main and not has_drink:
        # Upsell a drink
        drink = db.query(models.MenuItem).filter(models.MenuItem.category_id == 4, models.MenuItem.is_available == True).first()
        if drink: recommendations.append(drink)
    
    # 3. Popular Items (Collaborative filtering simulation)
    popular_items = db.query(models.MenuItem).join(models.UserPreference).order_by(models.UserPreference.order_count.desc()).limit(3).all()
    for item in popular_items:
        if item.id not in ordered_item_ids and item not in recommendations:
            recommendations.append(item)
            
    # If still few recs, just return top 3 items
    if len(recommendations) < 3:
        top_items = db.query(models.MenuItem).filter(models.MenuItem.is_available == True).limit(3).all()
        for item in top_items:
            if item.id not in ordered_item_ids and item not in recommendations:
                recommendations.append(item)
                
    return recommendations[:5]

@app.get("/ai/stats/prep-time-prediction")
def predict_prep_time(db: Session = Depends(get_db)):
    # Logic: If many orders are in 'COOKING' or 'RECEIVED' status, increase estimated prep time
    active_orders_count = db.query(models.Order).filter(models.Order.status.in_(["received", "cooking"])).count()
    load_factor = 1.0 + (active_orders_count * 0.1) # 10% increase per active order
    
    return {
        "active_orders": active_orders_count,
        "load_multiplier": round(load_factor, 2),
        "message": "High load detected" if active_orders_count > 5 else "Normal load"
    }
