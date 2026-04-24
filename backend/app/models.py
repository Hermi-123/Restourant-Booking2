from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from .database import Base
import datetime
import enum

class OrderStatus(str, enum.Enum):
    RECEIVED = "received"
    COOKING = "cooking"
    READY = "ready"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class Table(Base):
    __tablename__ = "tables"
    id = Column(Integer, primary_key=True, index=True)
    table_number = Column(Integer, unique=True, index=True)
    qr_code_id = Column(String, unique=True)
    sessions = relationship("TableSession", back_populates="table")

class TableSession(Base):
    __tablename__ = "table_sessions"
    id = Column(Integer, primary_key=True, index=True)
    session_token = Column(String, unique=True, index=True)
    table_id = Column(Integer, ForeignKey("tables.id"))
    status = Column(String, default="active") # active, closed
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    table = relationship("Table", back_populates="sessions")
    orders = relationship("Order", back_populates="session")

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    items = relationship("MenuItem", back_populates="category")

class MenuItem(Base):
    __tablename__ = "menu_items"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    price = Column(Float)
    estimated_prep_time = Column(Integer) # in minutes
    is_available = Column(Boolean, default=True)
    category_id = Column(Integer, ForeignKey("categories.id"))
    
    category = relationship("Category", back_populates="items")

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String, unique=True, index=True)
    table_session_id = Column(Integer, ForeignKey("table_sessions.id"))
    status = Column(Enum(OrderStatus), default=OrderStatus.RECEIVED)
    total_amount = Column(Float)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    session = relationship("TableSession", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    menu_item_id = Column(Integer, ForeignKey("menu_items.id"))
    quantity = Column(Integer)
    price_at_order = Column(Float)
    
    order = relationship("Order", back_populates="items")
    menu_item = relationship("MenuItem")

class UserPreference(Base):
    __tablename__ = "user_preferences"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True) # Could be a device ID or unique token
    menu_item_id = Column(Integer, ForeignKey("menu_items.id"))
    order_count = Column(Integer, default=1)
    
    menu_item = relationship("MenuItem")
