from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class SavingBase(BaseModel):
    amount: float = Field(..., gt=0)
    description: Optional[str] = None
    date: datetime = Field(default_factory=datetime.utcnow)

class SavingCreate(SavingBase):
    pass

class Saving(SavingBase):
    id: int

    class Config:
        from_attributes = True

class InvestmentBase(BaseModel):
    amount: float = Field(..., gt=0)
    description: Optional[str] = None
    date: datetime = Field(default_factory=datetime.utcnow)

class InvestmentCreate(InvestmentBase):
    pass

class Investment(InvestmentBase):
    id: int

    class Config:
        from_attributes = True 