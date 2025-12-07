from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from models.expense import Expense, Category
from schemas.expense import ExpenseCreate, CategoryCreate

def get_expense(db: Session, expense_id: int) -> Optional[Expense]:
    return db.query(Expense).filter(Expense.id == expense_id).first()

def get_expenses(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    category_ids: Optional[List[int]] = None
) -> List[Expense]:
    query = db.query(Expense)
    
    if start_date:
        query = query.filter(Expense.date >= start_date)
    if end_date:
        query = query.filter(Expense.date <= end_date)
    if category_ids:
        query = query.filter(Expense.categories.any(Category.id.in_(category_ids)))
    
    return query.offset(skip).limit(limit).all()

def create_expense(db: Session, expense: ExpenseCreate) -> Expense:
    # Get categories
    categories = db.query(Category).filter(Category.id.in_(expense.category_ids)).all()
    
    # Create expense
    db_expense = Expense(
        amount=expense.amount,
        date=expense.date,
        description=expense.description,
        categories=categories
    )
    
    db.add(db_expense)
    db.commit()
    db.refresh(db_expense)
    return db_expense

def update_expense(
    db: Session,
    expense_id: int,
    expense: ExpenseCreate
) -> Optional[Expense]:
    db_expense = get_expense(db, expense_id)
    if not db_expense:
        return None
    
    # Update basic fields
    db_expense.amount = expense.amount
    db_expense.date = expense.date
    db_expense.description = expense.description
    
    # Update categories
    categories = db.query(Category).filter(Category.id.in_(expense.category_ids)).all()
    db_expense.categories = categories
    
    db.commit()
    db.refresh(db_expense)
    return db_expense

def delete_expense(db: Session, expense_id: int) -> bool:
    db_expense = get_expense(db, expense_id)
    if not db_expense:
        return False
    
    db.delete(db_expense)
    db.commit()
    return True

# Category CRUD operations
def get_category(db: Session, category_id: int) -> Optional[Category]:
    return db.query(Category).filter(Category.id == category_id).first()

def get_categories(db: Session, skip: int = 0, limit: int = 100) -> List[Category]:
    return db.query(Category).offset(skip).limit(limit).all()

def create_category(db: Session, category: CategoryCreate) -> Category:
    db_category = Category(**category.model_dump())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

def delete_category(db: Session, category_id: int) -> bool:
    db_category = get_category(db, category_id)
    if not db_category:
        return False
    
    db.delete(db_category)
    db.commit()
    return True 