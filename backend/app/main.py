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
