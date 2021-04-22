def main(ctx):
  t = testing(ctx)
  m = manifest(ctx)
  r = readme(ctx)
  c = changes(ctx)
  n = notify(ctx)

  bs = [
    binary(ctx, 'linux'),
  ]

  ds = [
    docker(ctx, 'amd64'),
    docker(ctx, 'arm'),
    docker(ctx, 'arm64'),
  ]

  for b in bs:
    b['depends_on'].append(t['name'])
    c['depends_on'].append(b['name'])
    n['depends_on'].append(b['name'])

  for d in ds:
    d['depends_on'].append(t['name'])
    m['depends_on'].append(d['name'])
    r['depends_on'].append(d['name'])
    c['depends_on'].append(d['name'])
    n['depends_on'].append(d['name'])

  return [ t ] + bs + ds + [ m, r, c, n ]

def testing(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'testing',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'goenv',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'go env',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'vet',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make vet',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'staticcheck',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make staticcheck',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'lint',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make lint',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'test',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make test',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'codacy',
        'image': 'dronehippie/codacy:1',
        'pull': 'always',
        'settings': {
          'token': {
            'from_secret': 'codacy_token',
          },
        },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def binary(ctx, name):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': name,
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'goenv',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'go env',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make release-%s' % (name),
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'finish',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'commands': [
          'make release-finish',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'gpgsign',
        'image': 'dronehippie/gpgsign:1',
        'pull': 'always',
        'settings': {
          'key': {
            'from_secret': 'gpgsign_key',
          },
          'passphrase': {
            'from_secret': 'gpgsign_pass',
          },
          'files': [
            'dist/drone-%s-*' % ctx.repo.name,
          ],
          'excludes': [
            'dist/*.sha256',
          ],
          'detach_sign': True,
        },
        'when': {
          'ref': [
            'refs/tags/**',
          ],
        },
      },
      {
        'name': 'changes',
        'image': 'dronehippie/chglog:1',
        'pull': 'always',
        'settings': {
          'output': 'dist/CHANGELOG.md',
          'print': True,
          'query': ctx.build.ref.replace('refs/tags/v', '').split('-')[0],
        },
        'when': {
          'ref': [
            'refs/tags/**',
          ],
        },
      },
      {
        'name': 'release',
        'image': 'dronehippie/github-release:1',
        'pull': 'always',
        'settings': {
          'api_key': {
            'from_secret': 'github_token',
          },
          'files': [
            'dist/drone-%s-*' % ctx.repo.name,
          ],
          'title': ctx.build.ref.replace('refs/tags/', ''),
          'note': 'dist/CHANGELOG.md',
          'overwrite': True,
        },
        'when': {
          'ref': [
            'refs/tags/**',
          ],
        },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def docker(ctx, arch):
  if arch == 'amd64':
    platforms = [
      'linux/amd64',
    ]

    environment = {
      'GOARCH': 'amd64',
    }

  if arch == 'arm':
    platforms = [
      'linux/arm/v6',
    ]

    environment = {
      'GOARCH': 'arm',
      'GOARM': '6',
    }

  if arch == 'arm64':
    platforms = [
      'linux/arm64',
    ]

    environment = {
      'GOARCH': 'arm64',
    }

  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': arch,
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'goenv',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'environment': environment,
        'commands': [
          'go env',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'build',
        'image': 'webhippie/golang:1.16',
        'pull': 'always',
        'environment': environment,
        'commands': [
          'make build',
        ],
        'volumes': [
          {
            'name': 'gopath',
            'path': '/srv/app',
          },
        ],
      },
      {
        'name': 'docker',
        'image': 'dronehippie/buildx:1',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'docker_username',
          },
          'password': {
            'from_secret': 'docker_password',
          },
          'dockerfile': 'docker/Dockerfile.%s' % (arch),
          'repo': ctx.repo.slug,
          'push': ctx.build.event == 'pull_request',
          'auto_tag': True,
          'auto_tag_suffix': arch,
          'platforms': platforms,
        },
      },
    ],
    'volumes': [
      {
        'name': 'gopath',
        'temp': {},
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
        'refs/pull/**',
      ],
    },
  }

def manifest(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'manifest',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'upload',
        'image': 'dronehippie/manifest:1',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'docker_username',
          },
          'password': {
            'from_secret': 'docker_password',
          },
          'spec': 'docker/manifest.tmpl',
          'auto_tag': True,
          'ignore_missing': True,
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def changes(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'changes',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'clone': {
      'disable': True,
    },
    'steps': [
      {
        'name': 'clone',
        'image': 'dronehippie/git:1',
        'pull': 'always',
        'settings': {
          'actions': [
            'clone',
          ],
          'remote': 'https://github.com/%s' % (ctx.repo.slug),
          'branch': ctx.build.source if ctx.build.event == 'pull_request' else 'master',
          'path': '/drone/src',
          'netrc_machine': 'github.com',
          'netrc_username': {
            'from_secret': 'github_username',
          },
          'netrc_password': {
            'from_secret': 'github_token',
          },
        },
      },
      {
        'name': 'changes',
        'image': 'dronehippie/chglog:1',
        'pull': 'always',
        'settings': {
          'output': 'CHANGELOG.md',
          'print': True,
        },
      },
      {
        'name': 'upload',
        'image': 'dronehippie/git:1',
        'pull': 'always',
        'settings': {
          'actions': [
            'commit',
            'push',
          ],
          'message': 'Automated changelog update [skip ci]',
          'branch': 'master',
          'author_email': 'drone@webhippie.de',
          'author_name': 'Drone',
          'netrc_machine': 'github.com',
          'netrc_username': {
            'from_secret': 'github_username',
          },
          'netrc_password': {
            'from_secret': 'github_token',
          },
        },
        'when': {
          'ref': {
            'exclude': [
              'refs/pull/**',
            ],
          },
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
      ],
    },
  }

def readme(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'readme',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'upload',
        'image': 'dronehippie/readme:1',
        'pull': 'always',
        'settings': {
          'username': {
            'from_secret': 'docker_username',
          },
          'password': {
            'from_secret': 'docker_password',
          },
          'prefix': ctx.repo.namespace,
          'name': ctx.repo.name,
          'description': '',
          'readme': 'README.md',
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
      ],
    },
  }

def notify(ctx):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'notify',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'clone': {
      'disable': True,
    },
    'steps': [
      {
        'name': 'telegram',
        'image': 'dronehippie/telegram:1',
        'pull': 'always',
        'settings': {
          'token': {
            'from_secret': 'telegram_token',
          },
          'recipient': {
            'from_secret': 'telegram_recipient',
          },
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
      'status': [
        'failure',
      ],
    },
  }
