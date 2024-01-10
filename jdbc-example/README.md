# JDBC Authentication Example using Form Login/Basic Auth

## This project is an example of securing your API's using username and password stored in database

There are 2 ways to use authenticate using JDBC.

1. [Using the default schema provided by Spring Security](https://docs.spring.io/spring-security/reference/servlet/authentication/passwords/jdbc.html#servlet-authentication-jdbc-schema-user):-
   This only requires schema creation and insertion of user/authority data and spring takes care of rest.
2. Using a custom schema that I will explain below

## Schema Set Up
<ul>
    <li>This project uses an in-memory h2 database to store data</li>
    <li>Create User entity that can have customized fields but it must implement UserDetails interface and override
        methods
    </li>
    <li>UserDetails is used as Principal by Spring Security. To allow usage of custom schema, we need to provide custom implmentation of various methods like getUsername, getPassword etc. if we are changing fieldnames</li>
    <li>Create Authority entity which are high-level permissions the user is granted. Two examples are roles and
        scopes
    </li>
    <li>User would have associated list of authorities. User would have one-to-many relationship with authority, it will
        be loaded eagerly as it's used by Spring for authorization
    </li>
    <li>spring.jpa.hibernate.ddl-auto=create in application.properties would create schemas in h2 database on spring
        boot start-up
    </li>
    <li>data.sql in src/main/resources can have insert statements to initialize the data in the schema</li>
    <li>It is important to set below properties so that spring creates schema before running data.sql
        <ul>
            <li>spring.datasource.initialization-mode=always</li>
            <li>spring.jpa.defer-datasource-initialization=true</li>
        </ul>
    </li>
</ul>

## Wiring it all together

<ul>
    <li>DemoController has two endpoints:
        <ul>
            <li><b>/home:</b> It should be accessed only by a user with role USER</li>
            <li><b>/customer:</b> It should be accessed only by a user with role ADMIN</li>
        </ul>
    </li>
    <li>Create UserService that implements UserDetailsService and provides implementation for loadUserByUsername method
        <ul>
            <li>UserDetailsService is used by DaoAuthenticationProvider for retrieving a username, a password, and other
                attributes for authenticating with a username and password. Spring Security provides in-memory and JDBC
                implementations of UserDetailsService.
            </li>
            <li>We have defined custom authentication by exposing a custom UserDetailsService as a bean by implementing
                the interface
            </li>
        </ul>
    </li>
    <li>Create SecurityFilterChain bean in WebSecurityConfig configuration class
        <ul>
            <li>Using RequestMatcher along with hasAuthority, I have configured that /home can be accessed only by USER
                with ROLE_USER and /customer by USER with ROLE_ADMIN
            </li>
            <li>.formLogin(withDefaults()) tells Spring Security to render a default login page</li>
            <li>We can also plug our own login page or custom login endpoint to do authentication</li>
        </ul>
    </li>
    <li>Create passwordEncoder bean in WebSecurityConfig configuration class
        <ul>
            <li>You can use NoOpPasswordEncoder if you want to use plain text passwords</li>
            <li>We have used BCryptPasswordEncoder that uses bcrypt algorithm to hash the passwords. This means we have
                stored encrypted passwords in data.sql
            </li>
            <li>You can use Spring CLI or online websites to encrypt a password using bcrypt</li>
        </ul>
    </li>
    <li>Create AuthenticationManager bean in WebSecurityConfig configuration class to pass our custom UserDetailsService
        and PasswordEncoder to DaoAuthenticationProvider
    </li>
</ul>