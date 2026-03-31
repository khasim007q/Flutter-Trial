from sqlalchemy import Column, Integer, String, Boolean, Date, ForeignKey, DateTime
from sqlalchemy.orm import relationship
import datetime

from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String, nullable=True)
    due_date = Column(Date)
    status = Column(String, default="To-Do") # "To-Do", "In Progress", "Done"
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)
    
    is_recurring = Column(Boolean, default=False)
    recurrence_type = Column(String, nullable=True) # "Daily", "Weekly"
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # self-referential relationship to easily get the blocking task
    blocked_by = relationship("Task", remote_side=[id])

