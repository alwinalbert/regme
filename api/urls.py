from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserRegisterView, HallViewSet, BookingViewSet
from django.urls import path
from .views import ForgotPasswordView, ResetPasswordView

router = DefaultRouter()
router.register(r"halls", HallViewSet, basename="hall")
router.register(r"bookings", BookingViewSet, basename="booking")

urlpatterns = [
    path("register/", UserRegisterView.as_view(), name="user-register"),  # ✅ add this
    path("", include(router.urls)),
    path("forgot-password/",ForgotPasswordView.as_view(),name="forgot-password"),
    path("reset-password/",ResetPasswordView.as_view(),name="reset-password"),
]