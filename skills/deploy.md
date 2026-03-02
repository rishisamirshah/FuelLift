Deploy FuelLift to TestFlight via Fastlane.

Steps:
1. Verify the working directory is clean: `git status`
2. Ensure all changes are committed — warn the user if there are uncommitted changes
3. Run `cd FuelLift && bundle exec fastlane ios beta`
4. Monitor the output for:
   - Certificate/provisioning issues (Match)
   - Build failures
   - Upload failures
5. Report the build number and success/failure status

Required environment variables (must be set as GitHub Secrets or locally):
- ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY
- GOOGLE_PLACES_API_KEY, SPOONACULAR_API_KEY
- DEVELOPMENT_TEAM
- ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_CONTENT
- MATCH_GIT_URL, MATCH_PASSWORD

If deploying locally, ensure `bundle install` has been run in the FuelLift/ directory first.
The Fastlane beta lane: setup_ci → match → increment_build_number → build_app → upload_to_testflight.
