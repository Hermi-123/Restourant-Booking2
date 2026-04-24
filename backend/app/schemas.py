from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from enum import Enum

class OrderStatus(str, Enum):
    RECEIVED = "received"
    COOKING = "cooking"
    READY = "ready"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class MenuItemBase(BaseModel):
    name: str
    description: str
    price: float
    estimated_prep_time: int
    is_available: bool = True
    category_id: int

class MenuItemCreate(MenuItemBase):
    pass

class MenuItem(MenuItemBase):
    id: int
    class Config:
        orm_mode = True

class CategoryBase(BaseModel):
    name: str

class Category(CategoryBase):
    id: int
    items: List[MenuItem] = []
    class Config:
        orm_mode = True

class TableSessionBase(BaseModel):
    table_id: int

class TableSession(TableSessionBase):
    id: int
    session_token: str
    status: str
    created_at: datetime
    class Config:
        orm_mode = True

class OrderItemBase(BaseModel):
    menu_item_id: int
    quantity: int

class OrderItem(OrderItemBase):
    id: int
    price_at_order: float
    class Config:
        orm_mode = True

class OrderCreate(BaseModel):
    items: List[OrderItemBase]

class Order(BaseModel):
    id: int
    order_number: str
    table_session_id: int
    status: OrderStatus
    total_amount: float
    created_at: datetime
    items: List[OrderItem]
    class Config:
        orm_mode = True

class TableBase(BaseModel):
    table_number: int
    qr_code_id: str

class Table(TableBase):
    id: int
    class Config:
        orm_mode = True
