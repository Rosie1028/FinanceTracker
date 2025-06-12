from sqlalchemy.orm import Session
from datetime import datetime
from typing import List, Optional
from models.income import Income
from schemas.income import IncomeCreate

def create_income(db: Session, income: IncomeCreate) -> Income:
    db_income = Income(
        amount=income.amount,
        description=income.description,
        date=income.date,
        source=income.source
    )
    db.add(db_income)
    db.commit()
    db.refresh(db_income)
    return db_income

def get_incomes(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> List[Income]:
    query = db.query(Income)
    
    if start_date:
        query = query.filter(Income.date >= start_date)
    if end_date:
        query = query.filter(Income.date <= end_date)
    
    return query.order_by(Income.date.desc()).offset(skip).limit(limit).all()

def get_income(db: Session, income_id: int) -> Optional[Income]:
    return db.query(Income).filter(Income.id == income_id).first()

def update_income(db: Session, income_id: int, income: IncomeCreate) -> Optional[Income]:
    db_income = get_income(db, income_id)
    if db_income:
        for key, value in income.dict().items():
            setattr(db_income, key, value)
        db.commit()
        db.refresh(db_income)
    return db_income

def delete_income(db: Session, income_id: int) -> bool:
    db_income = get_income(db, income_id)
    if db_income:
        db.delete(db_income)
        db.commit()
        return True
    return False 