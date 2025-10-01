from django.urls import path, include
from . import views
from rest_framework.routers import DefaultRouter


router = DefaultRouter()
router.register(r"halls", views.HallViewSet, basename="hall")
router.register(r"bookings", views.BookingViewSet, basename="booking")

urlpatterns = [
    path('register/', views.register_view, name='register'),
    path('login/', views.login_view, name='login'),
    path("", include(router.urls)),
    path("forgot-password/", views.ForgotPasswordView.as_view(), name="forgot-password"),
    path("reset-password/", views.ResetPasswordView.as_view(), name="reset-password"),
    path("reset-password-form/<uuid:token>/", views.reset_password_form_view, name="reset-password-form"),
]