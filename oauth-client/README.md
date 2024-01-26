## About The Project

This project is a sample application which logs in usign github auth server using OAuth 2.0 and Spring Boot.

It is a single-page application using Spring Boot and Spring Security on the back-end. It uses plain jQuery on the frontend.

This implementation uses the native OAuth 2.0 support in Spring Boot.

### Built With

* [![Spring Boot][Spring.io]][Spring-url]
* [![Spring Boot][spring-security]][spring-security-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url]

## Single Sign On With GitHub

In this section, we will create minimal application that uses GitHub for authentication.
This will be quite easy by taking advantage of the autoconfiguration features in Spring Boot.

## Creating a New Project

First, let's create a Spring Boot application, which can be done in a number of ways.
The easiest is to go to https://start.spring.io and generate an empty project (choosing the "Web" dependency as a starting point).

## Add Landing Page
Create `index.html` in the `src/main/resources/static` folder
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>Authentication Using Oauth</title>
    <meta name="description" content=""/>
    <meta name="viewport" content="width=device-width"/>
    <base href="/"/>
    <link rel="stylesheet" type="text/css" href="/webjars/bootstrap/css/bootstrap.min.css"/>
    <script type="text/javascript" src="/webjars/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="/webjars/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/webjars/js-cookie/js.cookie.js"></script>
</head>
<body>
<h1>Welcome</h1>
<div class="container unauthenticated">
    <div>
        With GitHub: <a href="/oauth2/authorization/github">click here</a>
    </div>
    <div>
        With Google: <a href="/oauth2/authorization/google">click here</a>
    </div>
</div>
<div class="container authenticated" style="display:none">
    Logged in as: <span id="user"></span>
    <div>
        <button onClick="logout()" class="btn btn-primary">Logout</button>
    </div>
</div>
```
It's not necessary to have this page as Spring Boot has support for oauth login page out of box. But it's nice to have custom UI with logout functionality.

Add these dependencies in POM to add stylesheets that we have used above.
````xml
<dependency>
	<groupId>org.webjars</groupId>
	<artifactId>jquery</artifactId>
	<version>3.4.1</version>
</dependency>
<dependency>
	<groupId>org.webjars</groupId>
	<artifactId>bootstrap</artifactId>
	<version>4.3.1</version>
</dependency>
<dependency>
	<groupId>org.webjars</groupId>
	<artifactId>webjars-locator-core</artifactId>
</dependency>
````
## Authentication Using GitHub
Include the Spring Security OAuth 2.0 Client dependency
````xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>
````
By adding that, it will secure our app with OAuth 2.0 by default.

### Add a New GitHub App

To use GitHub's OAuth 2.0 authentication system for login, we must first [Add a new GitHub app](https://github.com/settings/developers).

Select "New OAuth App" and then the "Register a new OAuth application" page is presented.
Enter an app name and description.
Then, enter your app's home page, which should be http://localhost:8080, in this case.
Finally, indicate the Authorization callback URL as `http://localhost:8080/login/oauth2/code/github` and click _Register Application_.

### Add following properties in application.yml
````
spring.security.oauth2.client.registration.github.client-id=git-client-id
spring.security.oauth2.client.registration.github.client-secret=git-client-secret
spring.security.oauth2.client.registration.google.client-id=google-client-id
spring.security.oauth2.client.registration.google.client-secret=google-client-secret
````
Add OAuth 2.0 credentials we just created with GitHub, replacing `git-client-id` with the client id and `git-client-secret` with the client secret.

### Add /user Endpoint

Add the server-side endpoint just mentioned, calling it `/user`.
It will send back the currently logged-in user-name
````java
    @GetMapping("/user")
    public Map<String, Object> user(@AuthenticationPrincipal OAuth2User user){
        return Collections.singletonMap("name", user.getAttribute("name"));
    }
````

### Add javascript to call /user from index.html
````
<script type="text/javascript">
    $.get("/user", function(data) {
        $("#user").html(data.name);
        $(".unauthenticated").hide()
        $(".authenticated").show()
    });
</script>
````
### Add javascript for logout functionality
Spring Security has built in support for a /logout endpoint which will automatically take care of logout. 
However, The /logout endpoint requires a token to prevent CSRF. We will add few configuration in Spring for this later. 
First let's call the logout from index.html
````
var logout = function() {
    $.post("/logout", function() {
        $("#user").html('');
        $(".unauthenticated").show();
        $(".authenticated").hide();
    })
````
### Adding the CSRF Token in the Client

Add `js-cookie` dependency for adding the token from cookie to our logout request:

Add below in `pom.xml`
````
<dependency>
    <groupId>org.webjars</groupId>
    <artifactId>js-cookie</artifactId>
    <version>2.1.0</version>
</dependency>
````

And then, you can reference it in your HTML:

`index.html`
````
<script type="text/javascript" src="/webjars/js-cookie/js.cookie.js"></script>
````

Finally, you can use `Cookies` convenience methods in XHR to send the token:
Add following script to `index.html`
````
$.ajaxSetup({
  beforeSend : function(xhr, settings) {
    if (settings.type == 'POST' || settings.type == 'PUT'
        || settings.type == 'DELETE') {
      if (!(/^http:.*/.test(settings.url) || /^https:.*/
        .test(settings.url))) {
        // Only send the token to relative URLs i.e. locally.
        xhr.setRequestHeader("X-XSRF-TOKEN",
          Cookies.get('XSRF-TOKEN'));
      }
    }
  }
});
````

### Spring Security Configurations

1. We need to allow `unauthenticated users` to access `index.html` and `error`
2. We need to allow html page to load css and js from webjars
3. We need to add logout success URL
4. We need to send back XSRF-TOKEN in response that client will send us back to logout

To configure all this we will update the `SecurityFilterChain` using a config file as below:-
````
@Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        SimpleUrlAuthenticationFailureHandler handler = new SimpleUrlAuthenticationFailureHandler("/");
        CsrfTokenRequestAttributeHandler requestHandler = new CsrfTokenRequestAttributeHandler();
        // set the name of the attribute the CsrfToken will be populated on
        requestHandler.setCsrfRequestAttributeName(null);
        http.authorizeRequests(a ->
                        a.requestMatchers("/", "/index.html", "/error", "/webjars/**")
                                .permitAll()
                                .anyRequest()
                                .authenticated()
                ).csrf((csrf) -> csrf
                        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .csrfTokenRequestHandler(requestHandler)
                ).exceptionHandling(
                        e -> e.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
                ).logout(l -> l
                        .logoutSuccessUrl("/").permitAll()
                )
                .oauth2Login(Customizer.withDefaults());
        return http.build();
    }
````
## Let's run

Let's run the app and hit http://localhost:8080 to open login page
Click on `Login using Git` to take you to GitHub (if you are already logged in there you might not notice the redirect).
Click on the `Logout` button to logout of the app
You can open developer tools and inspect cookies to see JSESSIONID and XSRF-TOKEN

![/img/cookie.png](/oauth-client/img/cookie.png)



<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Spring.io]: https://img.shields.io/badge/SpringBoot-6DB33F?style=flat-square&logo=Spring&logoColor=white
[Spring-url]: https://spring.io/projects/spring-boot/
[spring-security]: https://img.shields.io/badge/Spring%20Security-6DB33F?style=for-the-badge&logo=springsecurity&logoColor=white
[spring-security-url]: https://docs.spring.io/spring-security/reference/index.html
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
