import uuid
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
  ROLE_CHOICES = [
    ('club', 'Club'),
    ('admin','Admin'),
    ('hall_incharge','Hall in Charge'),
    ('principal' , 'Principal'),
  ]
  email = models.EmailField(unique=True)
  role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='student')
    
  USERNAME_FIELD = 'email'
  REQUIRED_FIELDS = ['username']

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

class PasswordResetToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.expires_at:
            # Token expires in 1 hour
            self.expires_at = timezone.now() + timedelta(hours=1)
        super().save(*args, **kwargs)

    def is_expired(self):
        return timezone.now() > self.expires_at

    def __str__(self):
        return f"Password reset token for {self.user.email}"