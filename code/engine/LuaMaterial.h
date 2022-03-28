#pragma once

#include "system.h"
#include "Material.h"

#include <lua/lua.hpp>

auto material_new(lua_State* L) -> int
{
    char* matName = nullptr;
    unsigned int w = 1, h = 1;

    if (lua_gettop(L) == 1)
        matName = (char*)luaL_checkstring(L, 1);
    else if (lua_gettop(L) == 2)
    {
        w = static_cast<unsigned int>(luaL_checkinteger(L, 1));
        h = static_cast<unsigned int>(luaL_checkinteger(L, 2));
    }

    const auto mat = static_cast<CMaterial**>(lua_newuserdata(L, sizeof(CMaterial*)));

    if (matName)
        *mat = new CMaterial(TEXTURESLOT_ALBEDO, matName);
    else if (lua_gettop(L) == 2)
        *mat = new CMaterial(TEXTURESLOT_ALBEDO, w, h);
    else
        *mat = new CMaterial();

    luaL_setmetatable(L, L_MATERIAL);
    return 1;
}

static auto material_loadfile(lua_State* L) -> int
{
    auto mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const auto texName = static_cast<LPCSTR>(luaL_checkstring(L, 2));
    const auto userSlot = static_cast<unsigned int>(luaL_checkinteger(L, 3)) - 1;

    mat->CreateTextureForSlot(userSlot, (LPSTR)texName);

    return 0;
}

static auto material_getres(lua_State* L) -> int
{
    auto mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int userSlot = static_cast<unsigned int>(luaL_checkinteger(L, 2)) - 1;
    LPDIRECT3DTEXTURE9 h = mat->GetTextureHandle(userSlot);
    D3DSURFACE_DESC a;

    h->GetLevelDesc(0, &a);

    lua_newtable(L);

    lua_pushinteger(L, 1);
    lua_pushinteger(L, a.Width);
    lua_settable(L, 3);

    lua_pushinteger(L, 2);
    lua_pushinteger(L, a.Height);
    lua_settable(L, 3);

    lua_pushvalue(L, 3);

    return 1;
}

static auto material_loaddata(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int userSlot = static_cast<unsigned int>(luaL_checkinteger(L, 3)) - 1;
    const unsigned int width = static_cast<unsigned int>(luaL_checkinteger(L, 4));
    const unsigned int height = static_cast<unsigned int>(luaL_checkinteger(L, 5));

    mat->CreateTextureForSlot(userSlot, nullptr, width, height);
    //mat->UploadARGB(userSlot, 2, 2);

    return 0;
}

static auto material_getdata(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int userSlot = static_cast<unsigned int>(luaL_checkinteger(L, 3)) - 1;
    D3DSURFACE_DESC a;
    mat->GetTextureHandle(userSlot)->GetLevelDesc(0, &a);

    int pitch;
    unsigned int* buf = static_cast<unsigned int*>(mat->Lock(pitch,userSlot));

    lua_newtable(L);

    for (unsigned int i = 0; i < a.Width * a.Height; i++)
    {
        lua_pushinteger(L, i + 1ULL);
        lua_pushinteger(L, buf[i]);
        lua_settable(L, 3);
    }

    mat->Unlock(userSlot);

    lua_pushvalue(L, 3);

    return 1;
}

static auto material_setsampler(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int sampler = static_cast<unsigned int>(luaL_checkinteger(L, 2));
    const unsigned int val = static_cast<unsigned int>(luaL_checkinteger(L, 3));

    mat->SetSamplerState(sampler, val);

    return 0;
}

static auto material_getsampler(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int sampler = static_cast<unsigned int>(luaL_checkinteger(L, 2));

    lua_pushinteger(L, mat->GetSamplerState(sampler));
    return 1;
}

static auto material_gethandle(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int slot = static_cast<unsigned int>(luaL_checkinteger(L, 2)) - 1;

    lua_pushlightuserdata(L, static_cast<void*>(mat->GetTextureHandle(slot)));
    return 1;
}

static auto material_sethandle(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const unsigned int slot = static_cast<unsigned int>(luaL_checkinteger(L, 2)) - 1;
    const auto handle = static_cast<LPDIRECT3DTEXTURE9>(lua_touserdata(L, 3));

    mat->SetUserTexture(slot, handle);
    return 1;
}

static auto material_delete(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));

    mat->Release();

    return 0;
}

static auto material_setdiffuse(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    mat->SetDiffuse(luaH_getcolorlinear(L, 1));

    return 0;
}

static auto material_setambient(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    mat->SetAmbient(luaH_getcolorlinear(L, 1));

    return 0;
}

static auto material_setemission(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    mat->SetEmission(luaH_getcolorlinear(L, 1));

    return 0;
}

static auto material_setspecular(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    mat->SetSpecular(luaH_getcolorlinear(L, 1));

    return 0;
}

static auto material_setpower(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const auto val = static_cast<float>(luaL_checknumber(L, 2));
    mat->SetPower(val);

    return 0;
}

static auto material_setopacity(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const auto val = static_cast<float>(luaL_checknumber(L, 2));
    mat->SetOpacity(val);

    return 0;
}

static auto material_setalphaistransparency(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const bool val = static_cast<bool>(lua_toboolean(L, 2));
    mat->SetAlphaIsTransparency(val);

    return 0;
}

static auto material_setalphatest(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const bool val = static_cast<bool>(lua_toboolean(L, 2));
    mat->SetEnableAlphaTest(val);

    return 0;
}

static auto material_setalpharef(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const auto val = static_cast<DWORD>(luaL_checkinteger(L, 2));
    mat->SetAlphaRef(val);

    return 0;
}

static auto material_setshaded(lua_State* L) -> int
{
    CMaterial* mat = *static_cast<CMaterial**>(luaL_checkudata(L, 1, L_MATERIAL));
    const bool val = static_cast<bool>(lua_toboolean(L, 2));
    mat->SetShaded(val);

    return 0;
}

static void LuaMaterial$Register(lua_State* L)
{
    lua_register(L, L_MATERIAL, material_new);
    luaL_newmetatable(L, L_MATERIAL);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");

    REGC("setSamplerState", material_setsampler);
    REGC("getSamplerState", material_getsampler);

    REGC("loadFile", material_loadfile);
    REGC("loadData", material_loaddata);
    REGC("res", material_getres);
    REGC("data", material_getdata);
    REGC("getHandle", material_gethandle);
    REGC("setHandle", material_sethandle);

    REGC("setDiffuse", material_setdiffuse);
    REGC("setAmbient", material_setambient);
    REGC("setSpecular", material_setspecular);
    REGC("setEmission", material_setemission);
    REGC("setPower", material_setpower);
    REGC("setOpacity", material_setopacity);
    REGC("alphaIsTransparency", material_setalphaistransparency);
    REGC("alphaTest", material_setalphatest);
    REGC("setAlphaRef", material_setalpharef);
    REGC("setShaded", material_setshaded);

    REGC("__gc", material_delete);

    lua_pop(L, 1);
}
