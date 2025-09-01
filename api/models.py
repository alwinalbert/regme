from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
  ROLE_CHOICES = [
    ('club', 'Club'),
    ('admin','Admin'),
    ('hall_incharge','Hall in Charge'),
    ('Principal' , 'Principal'),
  ]
  role=models.CharField(max_length=20, choices=ROLE_CHOICES, default='club')

class Hall(models.Model):
  name=models.CharField(max_length=100, unique=True)
  def __str__(self):
    return self.name

class Booking(models.Model):
  STATUS_CHOICES=[
    ('pending','Pending'),
    ('hall_approved','Hall Approved'),
    ('principal_approved','Principal Appoved'),
    ('rejected','Rejected'),

  ]
  hall = models.ForeignKey(Hall, on_delete=models.CASCADE)
  requested_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
  date = models.DateField()
  time_slot = models.CharField(max_length=50)  # e.g. "10:00-12:00"
  status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

  def __str__(self):
      
      return f"{self.hall} - {self.date} - {self.time_slot}"
