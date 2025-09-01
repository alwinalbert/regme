from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserRegisterView, HallViewSet, BookingViewSet

router = DefaultRouter()
router.register(r"halls", HallViewSet, basename="hall")
router.register(r"bookings", BookingViewSet, basename="booking")

urlpatterns = [
    path("register/", UserRegisterView.as_view(), name="user-register"),  # ✅ add this
    path("", include(router.urls)),
]