from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CarLoanBase(BaseModel):
    month: str
    year: int
    principal_balance: float
    payoff_balance: float
    amount_paid: float
    principal: float
    finance: float
    ending_balance: float
    interest_ytd: Optional[float] = None

class CarLoanCreate(CarLoanBase):
    pass

class CarLoan(CarLoanBase):
    id: int

    class Config:
        from_attributes = True 