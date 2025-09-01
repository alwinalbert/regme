from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Hall, Booking

# Customize how User is shown in admin
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    fieldsets = BaseUserAdmin.fieldsets + (
        (None, {"fields": ("role",)}),
    )
    list_display = ("username", "email", "role", "is_staff", "is_active")
    list_filter = ("role", "is_staff", "is_superuser", "is_active")


@admin.register(Hall)
class HallAdmin(admin.ModelAdmin):
    list_display = ("name", "get_incharge")  # ✅ replace 'incharge' with custom method

    def get_incharge(self, obj):
        return obj.incharge.username if obj.incharge else "-"
    get_incharge.short_description = "In-Charge"


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ("hall", "requested_by", "date", "time_slot", "status")
    list_filter = ("status", "date")
    search_fields = ("hall__name", "requested_by__username")
