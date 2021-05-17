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
bool ClipLine(int dim, const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end, float& f_low, float& f_high){
    float f_dim_low, f_dim_high;

    //equação implícita da reta
    f_dim_low = (A.bbox_min[dim] - vec_origin[dim]) / (vec_end[dim] - vec_origin[dim]);
    f_dim_high = (A.bbox_max[dim] - vec_origin[dim]) / (vec_end[dim] - vec_origin[dim]);

    if(f_dim_high < f_dim_low)
        std::swap(f_dim_high, f_dim_low);

    if(f_dim_high < f_low)
        return false;

    if(f_dim_low > f_high)
        return false;

    f_low = std::max(f_dim_low, f_low);
    f_high = std::min(f_dim_high, f_high);

    if(f_low > f_high)
        return false;

    return true;
}

bool LINE_collision(const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end){

    float f_low = 0;
    float f_high = 0;

    for(int i = 0; i < 3; i++){
        if(!ClipLine(i, A, vec_origin, vec_end, f_low, f_high))
            return false;
    }

    //glm::vec4 d = vec_end - vec_origin;

    return true;

}
