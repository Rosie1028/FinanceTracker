from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class IncomeBase(BaseModel):
    amount: float
    description: Optional[str] = None
    date: datetime
    source: Optional[str] = None

class IncomeCreate(IncomeBase):
    pass

class Income(IncomeBase):
    id: int

    class Config:
        from_attributes = True 