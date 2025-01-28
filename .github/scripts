import os
import re
from datetime import datetime
from github import Github

def update_readme():
    # Initialize GitHub client
    g = Github(os.getenv('METRICS_TOKEN'))
    repo = g.get_repo("Speeku/SpeechMaster")

    # Get repository statistics
    contributors = list(repo.get_contributors())
    pulls = list(repo.get_pulls(state='all'))
    issues = list(repo.get_issues(state='all'))
    
    # Get current UTC time
    current_time = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

    # Create dynamic content
    dynamic_content = f"""
<div align="center">

# 🎙️ SpeechMaster

[![Last Updated](https://img.shields.io/badge/Last%20Updated-{current_time.replace(' ', '%20')}-brightgreen)](https://github.com/Speeku/SpeechMaster)
[![Contributors](https://img.shields.io/badge/Contributors-{len(contributors)}-blue)](https://github.com/Speeku/SpeechMaster/graphs/contributors)
[![PRs](https://img.shields.io/badge/Pull%20Requests-{len(pulls)}-purple)](https://github.com/Speeku/SpeechMaster/pulls)
[![Issues](https://img.shields.io/badge/Issues-{len(issues)}-red)](https://github.com/Speeku/SpeechMaster/issues)

## 📊 Repository Stats
<!-- START_SECTION:stats -->
- **Last Updated**: {current_time} UTC
- **Total Contributors**: {len(contributors)}
- **Total Pull Requests**: {len(pulls)}
- **Open Issues**: {len([i for i in issues if not i.pull_request])}
- **Language**: Swift (100%)
<!-- END_SECTION:stats -->

## 👥 Top Contributors
<!-- START_SECTION:contributors -->
"""

    # Add contributor information
    for contributor in contributors:
        dynamic_content += f"- [@{contributor.login}]({contributor.html_url}): {contributor.contributions} contributions\n"

    dynamic_content += "<!-- END_SECTION:contributors -->\n"

    # Read existing README
    with open('README.md', 'r') as file:
        content = file.read()

    # Update dynamic sections
    content = re.sub(
        r'<!-- START_SECTION:stats -->.*<!-- END_SECTION:stats -->',
        f'<!-- START_SECTION:stats -->\n{dynamic_content}\n<!-- END_SECTION:stats -->',
        content,
        flags=re.DOTALL
    )

    # Write updated README
    with open('README.md', 'w') as file:
        file.write(content)

if __name__ == '__main__':
    update_readme()
