#include <cstdlib>
#include <iostream>
#include "collisions.h"

bool BOX_collision(const SceneObject& A, const SceneObject& B){

    std::cout << "BBox_MAX_x : " << A.bbox_max[0];

    // Se tem sobreposição em todas as dimensões (x, y e z) está havendo uma colisão
    for(int i = 0; i < 3; i++){
        if(A.bbox_min[i] > B.bbox_max[i])
            return false;
        if(A.bbox_max[i] < B.bbox_min[i])
            return false;
    }

    //Se há sobreposição em todas as dimensões
    return true;
}

// Código obtido do vídeo: https://www.youtube.com/watch?v=3vONlLYtHUE -> 3:00
// "Corta" a linha em pedaços tentando encontrar o pedaço contido dentro do objeto se houver
// Essencialmente intersecção entre linha e plano
bool ClipLine(int dim, const SceneObject& A, const glm::vec4 p_origin, const glm::vec4 p_end, const glm::mat4 model, float& f_low, float& f_high){
    float f_dim_low, f_dim_high;

    //printf("A.bbox_min[%d] = %f\n", dim, A.bbox_min[dim]);
    //printf("A.bbox_max[%d] = %f\n", dim, A.bbox_max[dim]);

    //printf("vec_origin[%d] = %f\n", dim, vec_origin[dim]);
    //printf("vec_end[%d] = %f\n", dim, vec_end[dim]);

    glm::vec4 A_max = glm::vec4(A.bbox_max, 1.0f);
    glm::vec4 A_min = glm::vec4(A.bbox_min, 1.0f);

    A_min = model * A_min;
    A_max = model * A_max;

    //equação implícita da reta: (p - a) / d  -> d => (b - a)
    //f_dim_low = (A.bbox_min[dim] - vec_origin[dim]) / (vec_end[dim] - vec_origin[dim]);
    //f_dim_high = (A.bbox_max[dim] - vec_origin[dim]) / (vec_end[dim] - vec_origin[dim]);

    //equação implícita da reta: (p - a) / d  -> d => (b - a)
    f_dim_low = (A_min[dim] - p_origin[dim]) / (p_end[dim] - p_origin[dim]);
    f_dim_high = (A_max[dim] - p_origin[dim]) / (p_end[dim] - p_origin[dim]);

    //printf("f_dim_Low = %f\n", f_dim_low);
    //printf("f_dim_High = %f\n", f_dim_high);

    if(f_dim_high < f_dim_low)
        std::swap(f_dim_high, f_dim_low);

    //printf("After swap:\n");
    //printf("f_dim_Low = %f\n", f_dim_low);
    //printf("f_dim_High = %f\n", f_dim_high);

    if(f_dim_high < f_low)
        return false;

    if(f_dim_low > f_high)
        return false;

    f_low = std::max(f_dim_low, f_low);
    f_high = std::min(f_dim_high, f_high);

    if(f_low > f_high)
        return false;

    //printf("Returned true!!!!!!!!!!!\n");
    return true;
}

bool LINE_collision(const SceneObject& A, const glm::vec4 p_origin, const glm::vec4 p_end, const glm::mat4 model){

    float f_low = 0;
    float f_high = 0;

    //glm::vec4 A_max = glm::vec4(A.bbox_max, 1.0f);
    //glm::vec4 A_min = glm::vec4(A.bbox_min, 1.0f);

    for(int i = 0; i < 3; i++){
        //printf("Loop %d\n", i);
        if(!ClipLine(i, A, p_origin, p_end, model, f_low, f_high))
            return false;
    }

    //glm::vec4 d = vec_end - vec_origin;

    //int t = f_low;

    return true;

}

// Fonte: https://developer.mozilla.org/en-US/docs/Games/Techniques/3D_collision_detection
bool pointAABB_collision(const SceneObject& A, const glm::vec4 p, const glm::mat4 model){
    glm::vec4 A_min = glm::vec4(A.bbox_min, 1.0f);
	glm::vec4 A_max = glm::vec4(A.bbox_max, 1.0f);

    A_min = model * A_min;
    A_max = model * A_max;

    //std::cout << p.x << " " << p.y << " " << p.z << "\n";
    bool collision = (p.x >= A_min.x && p.x <= A_max.x) &&
         (p.y >= A_min.y && p.y <= A_max.y) &&
         (p.z >= A_min.z && p.z <= A_max.z);


    std::cout << (p.x >= A_min.x && p.x <= A_max.x) << " " << (p.y >= A_min.y && p.y <= A_max.y) << " " << (p.z >= A_min.z && p.z <= A_max.z) << "\n";
    if (collision){
        std::cout << "AABBPoint " << A.name << ": TRUE" << glfwGetTime() << "\n";
    }

    return collision;
}

// Fonte: https://developer.mozilla.org/en-US/docs/Games/Techniques/3D_collision_detection
bool pointAABB_collision2(const SceneObject& A, const glm::vec4 p, const glm::mat4 model){
    glm::vec4 A_min = glm::vec4(A.bbox_min, 1.0f);
	glm::vec4 A_max = glm::vec4(A.bbox_max, 1.0f);

    A_min = model * A_min;
    A_max = model * A_max;

    //std::cout << p.x << " " << p.y << " " << p.z << "\n";
    //bool collided = (p[0] >= A_min.x && p[0] <= A_max.x) &&
         //(p[1] >= A_min.y && p[1] <= A_max.y) &&
         //(p[2] >= A_min.z && p[2] <= A_max.z);

    bool collided = true;
    for(int dim = 0; dim < 3; dim++){
        if(!(p[dim] >= A_min[dim] && p[dim] <= A_max[dim]))
            collided = false;
    }


    std::cout << (p.x >= A_min.x && p.x <= A_max.x) << " " << (p.y >= A_min.y && p.y <= A_max.y) << " " << (p.z >= A_min.z && p.z <= A_max.z) << "\n";
    if (collided){
        std::cout << "AABBPoint " << A.name << ": TRUE" << glfwGetTime() << "\n";
    }

    return collided;
}
