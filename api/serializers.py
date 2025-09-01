
from rest_framework import serializers
from .models import User, Hall, Booking
from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ["id", "username", "email", "password", "role"]

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role']

class HallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hall
        fields = ['id', 'name']

class BookingSerializer(serializers.ModelSerializer):
    requested_by = UserSerializer(read_only=True)
    hall = HallSerializer(read_only=True)

    class Meta:
        model = Booking
        fields = ['id', 'hall', 'requested_by', 'date', 'time_slot', 'status']