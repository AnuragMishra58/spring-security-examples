# LDAP Authentication Example using Form Login
<a name="readme-top"></a>
## This project provides an example implementation for securing your API's using username and password stored in LDAP

## Project Setup

<ul>
    <li>This project uses Spring Boot 3 with Spring Security 6, configuration might differ for older versions of Spring Security</li>
    <li>It uses an embedded LDAP server</li>
    <li>UnboundId is added in POM that provides an open source LDAP server</li>
    <li>Add following additional dependencies to POM:-
        <ul>
            <li>spring-boot-starter-security</li>
            <li>spring-ldap-core</li>
            <li>spring-security-ldap</li>
            <li>unboundid-ldapsdk</li>
        </ul>
    </li>
   <li>Create a sample ldif file which would act as the source of user details. Refer test.ldif in src/main/resources</li>
   <li>ldif file has username stored in <b>uid</b> attribute</li>
   <li>ldif file has password stored in <b>userPassword</b> attribute</li>
   <li>I have used bcrypt hashed password in ldif instead of plain text</li>
</ul>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Wiring it all together

<ul>
    <li>DemoController has two endpoints:
        <ul>
            <li><b>/home:</b> It should be accessed only by a user with role <b>ROLE_DEVELOPERS</b></li>
            <li><b>/customer:</b> It should be accessed only by a user with role <b>ROLE_MANAGERS</b></li>
        </ul>
    </li>
    <li>Create SecurityFilterChain bean in WebSecurityConfig configuration class
        <ul>
            <li>Using RequestMatcher along with hasAuthority, I have configured that /home can be accessed only by USER
                with ROLE_DEVELOPERS and /customer by USER with ROLE_MANAGERS
            </li>
            <li>.formLogin(withDefaults()) tells Spring Security to render a default login page</li>
        </ul>
    </li>
    <li>Configure ldap Authentication using AuthenticationManagerBuilder by autowiring
        <ul>
            <li>Define userdn pattern "uid={0},ou=people"</li>
            <li>Define embedded ldap server url:- "ldap://localhost:8399/dc=anurag,dc=org"</li>
            <li>Define BCryptPasswordEncoder as passwordEncoder</li>
            <li>Define passwordAttribute to name of attribute that holds password in ldif file. In our case it is userPassword</li>
        </ul>
    </li>
    <li>Spring LDAP requires that three application properties be set in the application.properties` file:
      <ul>
            <li>spring.ldap.embedded.ldif=classpath:test.ldif # Defines ldif file to be used</li>
            <li>spring.ldap.embedded.base-dn=dc=springframework,dc=org</li>
            <li>spring.ldap.embedded.port=8389</li>
        </ul>
   </li>
</ul>
<p align="right">(<a href="#readme-top">back to top</a>)</p>
