/// Configuration injectée au build : `--dart-define-from-file=.env`
/// (ou `--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_PUBLISHABLE_KEY=…`).
/// Seules l'URL et la clé PUBLISHABLE sont utilisées — la clé secrète n'a jamais sa place dans une app.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
