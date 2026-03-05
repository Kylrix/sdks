from appwrite.client import Client
from appwrite.services.account import Account
from appwrite.services.databases import Databases
from appwrite.id import ID
from typing import Optional, List, Dict, Any, Union
import datetime
from kylrix.security import KylrixSecurity
from kylrix.pulse import KylrixPulse


class EcosystemConfig:
    DOMAIN = "kylrix.space"
    DEFAULT_ENDPOINT = "https://cloud.appwrite.io/v1"
    SUBDOMAINS = {
        "accounts": "accounts",
        "vault": "vault",
        "note": "note",
        "flow": "flow",
        "connect": "connect",
    }

    @staticmethod
    def get_url(subdomain: str, path: str = "") -> str:
        sub = EcosystemConfig.SUBDOMAINS.get(subdomain, subdomain)
        url = f"https://{sub}.{EcosystemConfig.DOMAIN}"
        if not path:
            return url
        return f"{url}/{path.lstrip('/')}"


class KylrixTheme:
    BRAND_PRIMARY = "#6366F1"
    BRAND_CREAMY = "#FDFCFB"
    BRAND_GLASS = "rgba(255, 255, 255, 0.7)"

    FONT_HEADING = "Clash Display"
    FONT_UI = "Satoshi"
    FONT_MONO = "JetBrains Mono"


class TableDB:
    @staticmethod
    def get_event_path(
        database_id: str, table_id: str, row_id: Optional[str] = None
    ) -> str:
        path = f"databases.{database_id}.tables.{table_id}"
        return f"{path}.rows.{row_id}" if row_id else f"{path}.rows"


class KylrixModule:
    def __init__(self, sdk: "Kylrix"):
        self.sdk = sdk


class ConnectModule(KylrixModule):
    def send_message(self, database_id: str, table_id: str, data: Dict[str, Any]):
        data["createdAt"] = datetime.datetime.now().isoformat()
        data["updatedAt"] = datetime.datetime.now().isoformat()
        return self.sdk.create_row(database_id, table_id, data)


class VaultModule(KylrixModule):
    def get_credentials(self, database_id: str, table_id: str, queries: List[str] = []):
        return self.sdk.list_rows(database_id, table_id, queries)


class FlowModule(KylrixModule):
    def create_task(self, database_id: str, table_id: str, data: Dict[str, Any]):
        if "status" not in data:
            data["status"] = "pending"
        if "priority" not in data:
            data["priority"] = "medium"
        return self.sdk.create_row(database_id, table_id, data)


class NoteModule(KylrixModule):
    def save_revision(self, database_id: str, table_id: str, data: Dict[str, Any]):
        data["createdAt"] = datetime.datetime.now().isoformat()
        return self.sdk.create_row(database_id, table_id, data)


class Kylrix:
    """The official Kylrix SDK for Python."""

    def __init__(self, project: str, endpoint: str = EcosystemConfig.DEFAULT_ENDPOINT):
        self.client = Client()
        self.client.set_endpoint(endpoint)
        self.client.set_project(project)

        self.account = Account(self.client)
        self.databases = Databases(self.client)

        # Identity & Security
        self.theme = KylrixTheme()
        self.config = EcosystemConfig()
        self.security = KylrixSecurity()
        self.pulse = KylrixPulse(self)

        # Modules

        self.connect = ConnectModule(self)
        self.vault = VaultModule(self)
        self.flow = FlowModule(self)
        self.note = NoteModule(self)

    def list_rows(self, database_id: str, table_id: str, queries: List[str] = []):
        return self.databases.list_documents(database_id, table_id, queries)

    def get_row(self, database_id: str, table_id: str, row_id: str):
        return self.databases.get_document(database_id, table_id, row_id)

    def create_row(
        self,
        database_id: str,
        table_id: str,
        data: Dict[str, Any],
        row_id: str = "unique()",
    ):
        final_id = ID.unique() if row_id == "unique()" else row_id
        return self.databases.create_document(database_id, table_id, final_id, data)

    def update_row(
        self, database_id: str, table_id: str, row_id: str, data: Dict[str, Any]
    ):
        return self.databases.update_document(database_id, table_id, row_id, data)

    def delete_row(self, database_id: str, table_id: str, row_id: str):
        return self.databases.delete_document(database_id, table_id, row_id)
