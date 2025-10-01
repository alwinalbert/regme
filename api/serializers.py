from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import User, Hall, Booking, PasswordResetToken
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
    hall_name=serializers.CharField(source="hall.name",read_only=True)
    requested_by_username = serializers.CharField(source="requested_by.username", read_only=True)
    
    # Add a writable hall_id field
    hall_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Booking
        fields = [
            "id", "hall_id", "hall_name",
            "requested_by", "requested_by_username",
            "event_name", "event_description",
            "date", "time_slot",
            "request_type", "status", "staff_remark","created_at"
        ]
        read_only_fields = ["requested_by", "status", "hall_name", "requested_by_username"]

    def create(self, validated_data):
        # Extract hall_id and set the hall object
        hall_id = validated_data.pop('hall_id')
        try:
            hall = Hall.objects.get(id=hall_id)
            validated_data['hall'] = hall
        except Hall.DoesNotExist:
            raise serializers.ValidationError("Hall does not exist")
        
        user = self.context["request"].user
        validated_data["requested_by"] = user
        return super().create(validated_data)
        
class BookingCalendarSerializer(serializers.ModelSerializer):
    title = serializers.CharField(source="hall.name", read_only=True)
    start = serializers.SerializerMethodField()
    end = serializers.SerializerMethodField()
    color = serializers.SerializerMethodField()

    class Meta:
        model = Booking
        fields = ["id", "title", "start", "end", "status", "color"]

    def get_start(self, obj):
        return f"{obj.date}T{obj.time_slot.split('-')[0]}:00"  # e.g. "2025-09-05T10:00:00"

    def get_end(self, obj):
        return f"{obj.date}T{obj.time_slot.split('-')[1]}:00"  # e.g. "2025-09-05T12:00:00"

    def get_color(self, obj):
        return {
            "pending": "yellow",
            "hall_approved": "blue",
            "principal_approved": "green",
            "rejected": "red",
        }.get(obj.status, "gray")

class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("No account with this email address exists.")
        return value    
    
class ResetPasswordSerializer(serializers.Serializer):
    token = serializers.UUIDField()
    new_password = serializers.CharField(write_only=True, min_length=6)

    def validate_token(self, value):
        try:
            reset_token = PasswordResetToken.objects.get(token=value)
            if reset_token.is_used:
                raise serializers.ValidationError("This reset token has already been used.")
            if reset_token.is_expired():
                raise serializers.ValidationError("This reset token has expired.")
            return value
        except PasswordResetToken.DoesNotExist:
            raise serializers.ValidationError("Invalid reset token.")

    def save(self):
        token = self.validated_data["token"]
        new_password = self.validated_data["new_password"]
        
        reset_token = PasswordResetToken.objects.get(token=token)
        user = reset_token.user
        user.set_password(new_password)
        user.save()
        
        # Mark token as used
        reset_token.is_used = True
        reset_token.save()
        
        return user
        
class BookingListSerializer(serializers.ModelSerializer):
    hall_name = serializers.CharField(source='hall.name', read_only=True)
    requested_by_name = serializers.CharField(source='requested_by.username', read_only=True)
    
    class Meta:
        model = Booking
        fields = ['id', 'hall_name', 'requested_by_name', 'event_name', 
                  'event_description', 'date', 'time_slot', 'request_type', 
                  'status', 'created_at']        