#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <vector>
#include <iostream>

std::vector<float> vertices = {
    -1.0, 1.0, 0.0, 1.0, //Top Left
    -1.0, -1.0, 0.0, 0.0, //Bottom Left
    1.0, 1.0, 1.0, 1.0, //Top Right
    1.0, -1.0, 1.0, 0.0 //Bottom Right
};

std::vector<unsigned int> indices = {
    0, 1, 2, //Upper Triangle
    2, 1, 3  //Lower Triangle 
};

const char* vertexSource = "#version 460 core\n"
"layout(location = 0) in vec2 aPos;\n"
"layout(location = 1) in vec2 aTexCoords;\n"
"out vec2 FragPos;\n"
"void main() {\n"
    "FragPos = aPos;\n"
    "gl_Position = vec4(aPos, 0.0, 1.0);\n"
"}";

const char* fragmentSource = "#version 460 core\n"
"layout(location = 0) out vec4 FragColor;\n"
"in vec2 FragPos;\n"
"uniform float uTime;\n"
"void main() {\n"
    "float param = sin(uTime * 2.0) * 0.5 + 0.5;\n"
    "vec3 color = mix(vec3(1.0, 1.0, 0.0), vec3(0.0, 0.5, 1.0), param);\n"
    "FragColor = vec4(color, param);\n"
"}";

int main(void) {
    GLFWwindow* window;

    if(!glfwInit()) {
        return -1;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
    if(!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    if(!gladLoadGL((GLADloadfunc)glfwGetProcAddress)) {
        return -1;
    }

    GLuint VAO, VBO, EBO;

    glCreateVertexArrays(1, &VAO);
    glCreateBuffers(1, &VBO);
    glCreateBuffers(1, &EBO);

    glNamedBufferStorage(VBO, sizeof(float) * vertices.size(), vertices.data(), 0);
    glNamedBufferStorage(EBO, sizeof(unsigned int) * indices.size(), indices.data(), 0);

    float stride = 4 * sizeof(float);
    glVertexArrayVertexBuffer(VAO, 0, VBO, 0, stride);
    glVertexArrayElementBuffer(VAO, EBO);

    glEnableVertexArrayAttrib(VAO, 0);
    glVertexArrayAttribFormat(VAO, 0, 2, GL_FLOAT, GL_FALSE, 0);
    glVertexArrayAttribBinding(VAO, 0, 0);

    glEnableVertexArrayAttrib(VAO, 1);
    glVertexArrayAttribFormat(VAO, 1, 2, GL_FLOAT, GL_FALSE, 0);
    glVertexArrayAttribBinding(VAO, 1, 0);

    GLuint shaderProgram, vertexShader, fragmentShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexSource, nullptr);
    glCompileShader(vertexShader);

    int success;
    char infoLog[512];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(vertexShader, 512, nullptr, infoLog);
        std::cout << infoLog << std::endl;
    }

    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentSource, nullptr);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(fragmentShader, 512, nullptr, infoLog);
        std::cout << infoLog << std::endl;
    }

    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if(!success) {
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cout << infoLog << std::endl;
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    glUseProgram(shaderProgram);
    GLint loc = glGetUniformLocation(shaderProgram, "uTime");
     
    {
        while(!glfwWindowShouldClose(window)) {

            float currentTime = static_cast<float>(glfwGetTime());

            glClear(GL_COLOR_BUFFER_BIT);

            glUseProgram(shaderProgram);
            glUniform1f(loc, currentTime);
            glBindVertexArray(VAO);
            glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);

            glfwSwapBuffers(window);
            glfwPollEvents();
        }

        glDeleteProgram(shaderProgram);

        glDeleteVertexArrays(1, &VAO);
        glDeleteBuffers(1, &EBO);
        glDeleteBuffers(1, &VAO);
    }

    glfwTerminate();
}