class Routes {
  static const root = "/";
  static const login = "/login";
  static const register = "/register";
  static const home = "/home";
  static const profile = "/profile";
  static const profileEdit="/profile-edit";
  static const createBlog="/create-blog";

  static String readBlog([ String? postId ]) => "/read-blog/${ postId ?? ':postId' }";
}
