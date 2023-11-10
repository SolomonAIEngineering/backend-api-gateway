module.exports = {
  branches: ['main'], // Change this to your main branch name
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    '@semantic-release/npm',
    '@semantic-release/github',
    {
      "path": "@semantic-release/exec",
      "cmd": "kustomize build path/to/your/kustomization > output.yaml"
    },
  ],
};