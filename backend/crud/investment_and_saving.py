from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from models.investment_and_saving import Saving, Investment
from schemas.investment_and_saving import SavingCreate, InvestmentCreate

def get_saving(db: Session, saving_id: int) -> Optional[Saving]:
    return db.query(Saving).filter(Saving.id == saving_id).first()

def get_savings(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
) -> List[Saving]:
    query = db.query(Saving)
    
    if start_date:
        query = query.filter(Saving.date >= start_date)
    if end_date:
        query = query.filter(Saving.date <= end_date)
    
    return query.offset(skip).limit(limit).all()

def create_saving(db: Session, saving: SavingCreate) -> Saving:
    db_saving = Saving(**saving.model_dump())
    db.add(db_saving)
    db.commit()
    db.refresh(db_saving)
    return db_saving

def update_saving(
    db: Session,
    saving_id: int,
    saving: SavingCreate
) -> Optional[Saving]:
    db_saving = get_saving(db, saving_id)
    if not db_saving:
        return None
    
    for key, value in saving.model_dump(exclude_unset=True).items():
        setattr(db_saving, key, value)
    
    db.commit()
    db.refresh(db_saving)
    return db_saving

def delete_saving(db: Session, saving_id: int) -> bool:
    db_saving = get_saving(db, saving_id)
    if not db_saving:
        return False
    
    db.delete(db_saving)
    db.commit()
    return True

# Investment CRUD operations

def get_investment(db: Session, investment_id: int) -> Optional[Investment]:
    return db.query(Investment).filter(Investment.id == investment_id).first()

def get_investments(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
) -> List[Investment]:
    query = db.query(Investment)
    
    if start_date:
        query = query.filter(Investment.date >= start_date)
    if end_date:
        query = query.filter(Investment.date <= end_date)
    
    return query.offset(skip).limit(limit).all()

def create_investment(db: Session, investment: InvestmentCreate) -> Investment:
    db_investment = Investment(**investment.model_dump())
    db.add(db_investment)
    db.commit()
    db.refresh(db_investment)
    return db_investment

def update_investment(
    db: Session,
    investment_id: int,
    investment: InvestmentCreate
) -> Optional[Investment]:
    db_investment = get_investment(db, investment_id)
    if not db_investment:
        return None
        
    for key, value in investment.model_dump(exclude_unset=True).items():
        setattr(db_investment, key, value)
        
    db.commit()
    db.refresh(db_investment)
    return db_investment

def delete_investment(db: Session, investment_id: int) -> bool:
    db_investment = get_investment(db, investment_id)
    if not db_investment:
        return False
    
    db.delete(db_investment)
    db.commit()
    return True 