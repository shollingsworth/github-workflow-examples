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
    actor: str = os.environ.get("GITHUB_ACTOR", "")
    head_ref: str = os.environ.get("GITHUB_HEAD_REF", "")
    job_name: str = os.environ.get("GITHUB_JOB", "")
    run_id: str = os.environ.get("GITHUB_RUN_ID", "")
    repo: str = os.environ.get("GITHUB_REPOSITORY", "")
    attempt: str = os.environ.get("GITHUB_RUN_ATTEMPT", "")

    @property
    def slack_run_url(self) -> str | None:
        check_vals = {
            "run_id": self.run_id,
            "repo": self.repo,
            "attempt": self.attempt,
        }
        if not all(check_vals.values()):
            LOG.warning(
                "Could not retreive run_url some values were empty %s",
                check_vals,
            )
            return None
        return (
            "<https://github.com/"
            f"repos/{self.repo}/actions/runs/"
            f"{self.run_id}/attempts/${self.attempt}|"
            f"{self.job_name}:{self.run_id}>"
        )


def get_slack_body(args: ArgsValue) -> bytes:
    dval = {
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": args.title,
                    "emoji": True,
                },
            },
            {
                "type": "divider",
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": args.body,
                },
            },
        ]
    }
    if args.slack_run_url:
        dval["blocks"].append(
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": args.slack_run_url,
                },
            }
        )
    retval = json.dumps(dval, indent=4)
    LOG.info("Sending:\n%s", retval)
    return retval.encode()


def process(args: ArgsValue):
    headers = {
        "Content-Type": "application/json",
    }
    body = get_slack_body(args)
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
    args = ArgsValue(**parser.parse_args().__dict__)
    process(args)


if __name__ == "__main__":
    main()
