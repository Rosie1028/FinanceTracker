from sqlalchemy import Column, Integer, Float, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class CarLoan(Base):
    __tablename__ = "car_loans"

    id = Column(Integer, primary_key=True, index=True)
    month = Column(String, nullable=False)
    year = Column(Integer, nullable=False)
    principal_balance = Column(Float, nullable=False)
    payoff_balance = Column(Float, nullable=False)
    amount_paid = Column(Float, nullable=False)
    principal = Column(Float, nullable=False)
    finance = Column(Float, nullable=False)  # Interest portion
    ending_balance = Column(Float, nullable=False)
    interest_ytd = Column(Float, nullable=True)
    
    def __repr__(self):
        return f"<CarLoan(id={self.id}, month={self.month} {self.year}, amount_paid={self.amount_paid}, principal={self.principal}, interest={self.finance})>" 