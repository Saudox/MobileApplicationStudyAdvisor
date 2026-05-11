from django.urls import path
from .views import CourseListView, CourseDetailView, CategoryListView

urlpatterns = [
    path('', CourseListView.as_view(), name='course-list'),
    path('categories/', CategoryListView.as_view(), name='category-list'),
    path('<str:code>/', CourseDetailView.as_view(), name='course-detail'),
]
