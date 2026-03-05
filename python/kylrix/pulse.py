from appwrite.services.realtime import Realtime
from typing import Callable, Any
from .client import TableDB


class KylrixPulse:
    """
    Standardized Pulse Orchestrator for Python.
    Handles ecosystem-wide signals and TableDB subscriptions.
    """

    def __init__(self, sdk):
        self.sdk = sdk
        self.realtime = Realtime(sdk.client)

    def on(
        self,
        event_name: str,
        database_id: str,
        table_id: str,
        callback: Callable[[Any], None],
    ):
        """
        Listens to ecosystem-wide "Pulse" signals.
        Automatically maps event paths to TableDB structure.
        """
        path = TableDB.get_event_path(database_id, table_id)

        def _wrapper(response):
            # Ecosystem convention: events are objects with 'type' and 'data'
            payload = response.get("payload", {})
            if payload.get("type") == event_name:
                callback(payload.get("data"))

        return self.realtime.subscribe([path], _wrapper)

    def subscribe_to_row(
        self,
        database_id: str,
        table_id: str,
        row_id: str,
        callback: Callable[[Any], None],
    ):
        """Subscribes to specific TableDB row updates."""
        path = TableDB.get_event_path(database_id, table_id, row_id)
        return self.realtime.subscribe(
            [path], lambda response: callback(response.get("payload"))
        )
