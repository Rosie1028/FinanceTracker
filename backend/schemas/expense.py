from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase):
    id: int

    class Config:
        from_attributes = True

class ExpenseBase(BaseModel):
    amount: float = Field(..., gt=0)
    description: Optional[str] = None
    date: datetime = Field(default_factory=datetime.utcnow)
    category_ids: List[int] = []

class ExpenseCreate(ExpenseBase):
    pass

class Expense(ExpenseBase):
    id: int
    categories: List[Category] = []

    class Config:
        from_attributes = True 