from rest_framework import serializers

class CourseSerializer(serializers.Serializer):
    code = serializers.CharField()
    name = serializers.CharField()
    difficulty = serializers.CharField()
    level = serializers.IntegerField()
    category = serializers.CharField(allow_null=True)

class CourseDetailSerializer(CourseSerializer):
    prerequisites = serializers.ListField(child=serializers.CharField())

class CategorySerializer(serializers.Serializer):
    name = serializers.CharField()
