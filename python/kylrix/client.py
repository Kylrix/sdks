from appwrite.client import Client
from appwrite.services.account import Account
from appwrite.services.databases import Databases


class Kylrix:
    """The official Kylrix SDK for Python."""

    def __init__(self, endpoint: str, project: str):
        self.client = Client()
        self.client.set_endpoint(endpoint)
        self.client.set_project(project)

        self.account = Account(self.client)
        self.databases = Databases(self.client)

    def get_domain(self, subdomain: str, base_domain: str = "kylrix.space") -> str:
        return f"https://{subdomain}.{base_domain}"
