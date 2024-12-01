#!/usr/bin/env bun

// cf. https://developer.mamezou-tech.com/blogs/2024/10/04/build-simple-github-org-admin-site/

import { Octokit } from "@octokit/core";
import fs from "fs";

const endpoint = process.env.GHE_URL || process.env.GHE_FQDN ? 'https://' + process.env.GHE_FQDN + '/api/graphql' : 'https://api.github.com/graphql' ;

if (!process.env.GITHUB_ORG_NAME) { throw new Error('GITHUB_ORG_NAME is not defined'); }
if (!process.env.GHE_TOKEN) { throw new Error('GHE_TOKEN is not defined'); }
const GITHUB_TOKEN: string = process.env.GHE_TOKEN;
const ORG_NAME: string = process.env.GITHUB_ORG_NAME;


const query = `
  query($orgName: String!, $cursor: String) {
    organization(login: $orgName) {
      membersWithRole(first: 100, after: $cursor) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            login
            name
          }
          role
        }
      }
    }
  }
`;

async function getOrganizationMembers(orgName: string) {
  let members: any[] = [];
  let hasNextPage = true;
  let cursor: string | null = null;

  while (hasNextPage) {
    const result = await Octokit.graphql.paginate({
      query,
      orgName,
      cursor,
      headers: {
        authorization: `token ${GITHUB_TOKEN}`,
      },
    });

    const { edges, pageInfo } = result.organization.membersWithRole;
    const nodesWithRole = edges.map((edge: any) => ({
      ...edge.node,
      role: edge.role,
    }));

    members = members.concat(nodesWithRole);
    cursor = pageInfo.endCursor;
    hasNextPage = pageInfo.hasNextPage;
  }

  return members;
}

async function saveMembersToFile(members: any, filePath: string) {
  try {
    fs.writeFileSync(filePath, JSON.stringify(members, null, 2));
    console.log(`Members saved to ${filePath}`);
  } catch (error) {
    console.error('Error saving members to file:', error);
  }
}

const members = await getOrganizationMembers(ORG_NAME);
await saveMembersToFile(members, 'data/members.json');
