from rest_framework import serializers
from courses.serializers import CourseSerializer

class RecommendationRequestSerializer(serializers.Serializer):
    completed = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    interests = serializers.ListField(child=serializers.CharField(), required=False, default=list)

class EligibilityRequestSerializer(serializers.Serializer):
    completed = serializers.ListField(child=serializers.CharField(), required=False, default=list)

class StatsRequestSerializer(serializers.Serializer):
    completed = serializers.ListField(child=serializers.CharField(), required=False, default=list)
