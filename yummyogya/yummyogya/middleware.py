from django.utils.deprecation import MiddlewareMixin


def process_request(request):
    setattr(request, '_dont_enforce_csrf_checks', True)


class DisableCSRF(MiddlewareMixin):
    pass
