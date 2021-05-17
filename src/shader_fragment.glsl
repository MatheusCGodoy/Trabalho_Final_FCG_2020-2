#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform vec4 camera_view;
uniform bool is_flashlight_on;
uniform bool is_flashlightambient_on;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPHERE 0
#define BUNNY  1
#define WALL  2
#define DEFAULT  3
#define LIGTHSWITCH  4
#define BOX 5
#define BOXNORMAL 6

uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI    3.14159265358979323846
#define M_PI_2 1.57079632679489661923

uniform vec3 Kdu;
uniform vec3 Ksu;
uniform vec3 Kau;



void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    //vec4 l = normalize(vec4(1.0,1.0,1.0,0.0));

    // Fonte de luz pontual / lâmpada da sala
    vec4 p_l = vec4(2.0f,1.6f,2.0f, 1.0f);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(p_l - p);


    //Dados da "Spotlight" nesse caso lanterna
    vec4 p_light = camera_position; // posição da fonte de luz
    vec4 vec_light = camera_view; //sentido da fonte de luz
    float degrees_light = 0.5236; //30º em radianos
    bool not_under_light = dot(normalize(p - p_light), normalize(vec_light)) < cos(degrees_light); //um ponto p não é iluminado sse cos(b) < cos(a)

    // Vetor que define o sentido da fonte de luz (lanterna) em relação ao ponto atual.
    vec4 vFlashlight = normalize(p_light - p);  // Luz "sai" da camera em direção ao ponto p

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // half vector - blinn-phong
    vec4 h = (l + v)/length(l + v);

    //para não ter que calcular multiplas vezes o produto interno de n e l:
    float dot_n_l = dot(n,l);

    // Vetor que define o sentido da reflexão especular ideal.
    //vec4 r = -l + 2*n*(dot_n_l);// PREENCHA AQUI o vetor de reflexão especular ideal

    // Vetor que define o sentido da reflexão especular ideal - lanterna.
    //vec4 r_flash = -vFlashlight + 2*n*(dot(n, vFlashlight));

    // half vector - mas em relação a lanterna - blinn-phong
    vec4 h_flash = (vFlashlight + v)/length(vFlashlight + v);

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    vec3 Kd0 = vec3(0.0, 0.0, 0.0);
    bool hasKD0 = false;

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPHERE )
    {
        // PREENCHA AQUI as coordenadas de textura da esfera, computadas com
        // projeção esférica EM COORDENADAS DO MODELO. Utilize como referência
        // o slides 134-150 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // A esfera que define a projeção deve estar centrada na posição
        // "bbox_center" definida abaixo.

        // Você deve utilizar:
        //   função 'length( )' : comprimento Euclidiano de um vetor
        //   função 'atan( , )' : arcotangente. Veja https://en.wikipedia.org/wiki/Atan2.
        //   função 'asin( )'   : seno inverso.
        //   constante M_PI
        //   variável position_model

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0; // centro da esfera
        float radius = 1; //raio da esfera
        vec4 p_circle = bbox_center + radius*((position_model - bbox_center)/length(position_model - bbox_center)); //ponto do modelo projetado na superficie da esfera

        float theta = atan(p_circle.x, p_circle.z);
        float phi = asin(p_circle.y/radius);

        U = (theta + M_PI) / (2 * M_PI);
        V = (phi + M_PI_2) / M_PI;


        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
        vec3 Kd0 = texture(TextureImage0, vec2(U,V)).rgb;

        //Obtemos a refletancia difusa da segunda textura
        vec3 Kd1 = texture(TextureImage1, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        float i=0;

        i = abs(dot(n,l)); // como dot(n,l) pode ser negativo -> val absoluto

        //color = Kd0 * (lambert + 0.01); //orig
        //Kd = Kd1*((i - lambert) + 0.1) + Kd0*(lambert + 0.01);

        // Propriedades espectrais da esfera
        Kd = vec3(1.0,1.0,1.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(1.0,1.0,1.0); //Como a esfera está sendo utilizada como representação da lâmpada
        q = 1.0;

    }
    else if ( object_id == BUNNY )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // projeção planar XY em COORDENADAS DO MODELO. Utilize como referência
        // o slides 99-104 do documento Aula_20_Mapeamento_de_Texturas.pdf,
        // e também use as variáveis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da variável 'p_v' utilizando
        // 'h' no slides 158-160 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // Veja também a Questão 4 do Questionário 4 no Moodle.

        /* float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        // projeção planar XY em COORDENADAS DO MODELO.
        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.y - miny)/(maxy - miny);

        Kd = texture(TextureImage0, vec2(U,V)).rgb; */
        Kd = vec3(0.8,0.4,0.08);
        // Propriedades espectrais do coelho
        //Kd = vec3(0.08,0.4,0.8);
        Ks = vec3(0.8,0.8,0.8);
        Ka = vec3(0.04,0.04,0.04);
        //q = 32.0; //phong
        q = 80; //blinn-phong
    }
    else if ( object_id == WALL )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        // Propriedades espectrais do plano
        //Kd = texture(TextureImage0, vec2(U,V)).rgb;


        Kd = vec3(0.0,0.5,1.0); //vec3(0.2,0.3,1.0);
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 100.0;
    }
    else if ( object_id == DEFAULT ) {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;



        // Propriedades espectrais do plano
        //Kd = texture(TextureImage0, vec2(U,V)).rgb;
        Ka = Kau;
        Kd = Kdu;
        Ks = Ksu;
        q = 1.0;
    }
    else if ( object_id == LIGTHSWITCH ) {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        hasKD0 = true;
        Kd0 = texture(TextureImage0, vec2(U,V)).rgb;

        // Propriedades espectrais do plano
        //Kd = texture(TextureImage0, vec2(U,V)).rgb;
        Ka = Kau;
        Kd = Kdu;
        Ks = Ksu;
        q = 1.0;
    } else if ( object_id == BOX ) {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        hasKD0 = true;
        Kd0 = texture(TextureImage2, vec2(U,V)).rgb;

        


        // Propriedades espectrais do plano
        //Kd = texture(TextureImage0, vec2(U,V)).rgb;
        Ka = Kau;
        Kd = Kdu;
        Ks = Ksu;
        q = 1.0;

        if(is_flashlight_on && !not_under_light){
            Kd = vec3(0.0,0.2,0.0);;
        }
    }
    else if ( object_id == BOXNORMAL ) {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        hasKD0 = true;
        Kd0 = texture(TextureImage2, vec2(U,V)).rgb;

        // Propriedades espectrais do plano
        //Kd = texture(TextureImage0, vec2(U,V)).rgb;
        Ka = Kau;
        Kd = Kdu;
        Ks = Ksu;
        q = 1.0;

    }
    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }

    vec3 Iflash = vec3(1.0f,1.0f,1.0f);

    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0f,1.0f,1.0f);

    float light_ambient = 0.0;

    if(is_flashlightambient_on){
        light_ambient = 1.0;
    }


    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2f,0.2f,0.2f);//vec3(0.5f,0.5f,0.5f);

    // Termo difuso utilizando a lei dos cossenos de Lambert
    //vec3 lambert_diffuse_term = vec3(0.0,0.0,0.0);
    vec3 lambert_diffuse_term = Kd * I * max(0, dot_n_l) * light_ambient;// PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka * Ia * light_ambient * light_ambient;

    // Termo especular utilizando o modelo de iluminação de Phong
    //vec3 phong_specular_term  = Ks * I * pow(max(0, dot(r, v)), q); // PREENCH AQUI o termo especular de Phong

    // Termo especular utilizando o modelo de iluminação de Blinn-Phong
    vec3 phong_specular_term  = Ks * I * pow(max(0, dot(n, h)), q) * light_ambient; // PREENCH AQUI o termo especular de Phong


    //LANTERNA
    // Termo difuso utilizando a lei dos cossenos de Lambert
    //vec3 lambert_diffuse_term = vec3(0.0,0.0,0.0);
    vec3 diffuse_flash = Kd * Iflash * max(0, dot(n, vFlashlight));// PREENCHA AQUI o termo difuso de Lambert

    // Termo especular utilizando o modelo de iluminação de Phong
    //vec3 specular_flash  = Ks * Iflash * pow(max(0, dot(r_flash, v)), q); // PREENCH AQUI o termo especular de Phong

    // Termo especular utilizando o modelo de iluminação de Blinn-Phong
    vec3 specular_flash  = Ks * Iflash * pow(max(0, dot(n, h_flash)), q); // PREENCH AQUI o termo especular de Phong


    float dist_to_p = length(camera_position - p); // distancia da câmera até o ponto p
    if(dist_to_p < 0.7f)
        dist_to_p = 0.7f;

    float lswitch = 1.0f; // luz direcional está ligada ou não
    float intensity = (10.0f/(dist_to_p*dist_to_p))*max(abs(dot(normalize(p - p_light), normalize(vec_light)) - cos(degrees_light)),0);//abs(dot(normalize(p - p_light), normalize(vec_light)) - cos(degrees_light)); //1.0f

    if(!is_flashlight_on)
        intensity = 0.0f;

    if(not_under_light){ // se não é iluminado pela lanterna
        intensity = 0.0f;
    }

    //color = Kd0 * (lambert + 0.01);
    //color = lambert_diffuse_term + ambient_term; // para testar sem iluminação especular
    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
    if (hasKD0){
        color = Kd0 * lswitch*(lambert_diffuse_term + phong_specular_term + ambient_term) + intensity*(diffuse_flash + specular_flash);
    } else {
        color = lswitch*(lambert_diffuse_term + phong_specular_term + ambient_term) + intensity*(diffuse_flash + specular_flash);
    }

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}

