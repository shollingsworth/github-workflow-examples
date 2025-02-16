#!/usr/bin/env python3
"""Simple slack webhook sender."""

import argparse
import json
import logging
import os
from typing import NamedTuple

from urllib3 import request

logging.basicConfig(level=logging.INFO)
LOG = logging.getLogger("slack-send")


class ArgsValue(NamedTuple):
    webhook: str
    title: str
    body: str
    job_url: str | None = None
    job_id: str | None = None
    actor: str = os.environ.get("GITHUB_ACTOR", "")
    head_ref: str = os.environ.get("GITHUB_HEAD_REF", "")
    job_name: str = os.environ.get("GITHUB_JOB", "")
    run_id: str = os.environ.get("GITHUB_RUN_ID", "")
    repo: str = os.environ.get("GITHUB_REPOSITORY", "")

    @property
    def slack_run_url(self) -> tuple[str, str, str] | None:
        check_run_vals = {
            "run_id": self.run_id,
            "repo": self.repo,
        }
        if self.job_url is not None:
            return (
                "Job Run:",
                f"{self.run_id}/{self.job_id}",
                self.job_url,
            )
        if not all(check_run_vals.values()):
            LOG.warning(
                "Could not retreive run_url some values were empty %s",
                check_run_vals,
            )
            return None
        url = "/".join(
            [
                f"<https://github.com{self.repo}/actions/runs",
                f"{self.run_id}",
            ]
        )
        return (
            "Workflow Run:",
            "{self.run_id}",
            url,
        )

    def get_slack_body(self) -> bytes:
        blocks = []
        blocks.extend(
            [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": self.title,
                        "emoji": True,
                    },
                },
                {
                    "type": "divider",
                },
            ]
        )
        msgs = []
        # insert link at top if it exists
        if self.slack_run_url is not None:
            prefix, link_title, link_url = self.slack_run_url
            msgs.append(f"{prefix} <{link_url}| {link_title}>")
        # insert actor
        if self.actor is not None:
            msgs.append(
                f"Run Actor: <https://github.com/{self.actor} | @{self.actor}>"
            )

        if msgs:
            blocks.append(
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "\n".join(msgs),
                    },
                }
            )
        blocks.append(
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": self.body,
                },
            },
        )
        retval = json.dumps({"blocks": blocks}, indent=4)
        LOG.info("Sending:\n%s", retval)
        return retval.encode()


def process(args: ArgsValue):
    headers = {
        "Content-Type": "application/json",
    }
    body = args.get_slack_body()
    r = request(
        "POST",
        args.webhook,
        headers=headers,
        body=body,
    )
    status = r.status
    ok_status = 200
    if status != ok_status:
        rinfo = dict(r.info())
        txt = r.data.decode("utf-8")
        LOG.error(
            "Request Response Error: %s, %s\n%s",
            status,
            txt,
            json.dumps(rinfo, indent=4),
        )
        return
    resp = r.data
    out: str = ""
    try:
        out = json.dumps(json.loads(resp), indent=4)
    except json.JSONDecodeError:
        out = resp.decode("utf-8")
    LOG.info("Request Response: %s, %s", status, out)


def main() -> None:
    """Run main function."""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=__doc__,
        add_help=True,
    )
    parser.add_argument(
        "--webhook",
        "-w",
        help="Slack webhook url",
        required=True,
        type=str,
    )
    parser.add_argument(
        "--title",
        "-t",
        help="title for webhook",
        required=True,
        type=str,
    )
    parser.add_argument(
        "--body",
        "-b",
        help="Markdown Text Body",
        required=True,
        type=str,
    )
    parser.add_argument(
        "--job-url",
        "-j",
        help="Job URL needed (useful for failures)",
        required=False,
        default=None,
        type=str,
    )
    parser.add_argument(
        "--job-id",
        "-i",
        help="Job ID",
        required=False,
        default=None,
        type=str,
    )
    args = ArgsValue(**parser.parse_args().__dict__)
    process(args)


if __name__ == "__main__":
    main()
