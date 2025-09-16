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
  REQUEST_CHOICES = [
    ("reserve","Reserve"),
    ("permissions","Permissions"),
  ]
  STATUS_CHOICES=[
    ('draft','Draft'),
    ('pending','Pending Approval'),
    ('reserved','Reserved'),
    ('hall_approved','Hall Approved'),
    ('principal_approved','Principal Appoved'),
    ("forward to dean","Forward to Dean"),
    ('Dean approved','Approved by Dean'),
    ('rejected','Rejected'),

  ]
  hall = models.ForeignKey(Hall, on_delete=models.CASCADE)
  requested_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
  event_name= models.CharField(max_length=200)
  event_description= models.CharField(max_length=300)
  date = models.DateField()
  time_slot = models.CharField(max_length=50)  # e.g. "10:00-12:00"
  request_type = models.CharField(max_length=20,choices=REQUEST_CHOICES, default="permission")
  status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
  created_at= models.DateTimeField(auto_now_add=True)
  staff_remark=models.TextField(blank=True,null=False)#To give suggestions
  Princi_remark=models.TextField(blank=True,null=False)
  dean_remark=models.TextField(blank=True,null=False)


  def __str__(self):
      
      return f"{self.hall} - {self.date} - {self.time_slot}"
