# pyrefly: ignore [missing-import]
from django.urls import path
from .views import RecommendationView, EligibilityView, PrerequisiteTreeView, StatsView, AIChatView

urlpatterns = [
    path('recommend/', RecommendationView.as_view(), name='advisor-recommend'),
    path('eligible/', EligibilityView.as_view(), name='advisor-eligible'),
    path('prerequisites/<str:code>/', PrerequisiteTreeView.as_view(), name='advisor-prereq-tree'),
    path('stats/', StatsView.as_view(), name='advisor-stats'),
    path('ai-chat/', AIChatView.as_view(), name='advisor-ai-chat'),
]