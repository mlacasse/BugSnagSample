// © You i Labs Inc. 2000-2020. All rights reserved.
#if defined(YI_LINUX) || defined(YI_WIN32) || defined(YI_OSX)
#    if defined(YI_GLFW)

#        include <event/YiActionEvent.h>
#        include <event/YiEvent.h>
#        include <event/YiKeyEvent.h>
#        include <framework/YiFramework.h>
#        include <framework/YiScreen.h>
#        include <utility/YiDir.h>
#        include <utility/YiFile.h>
#        include <utility/YiUtilities.h>

#        include "AppFactory.h"
#        include "framework/YiAppContext.h"
#        include "logging/YiLogger.h"

#        ifdef YI_OSX
#            include <mach-o/dyld.h>
#        endif

#        include <GLFW/glfw3.h>

#        include <glm/gtc/epsilon.hpp>
#        include <glm/vec2.hpp>

#        ifndef APP_FULLSCREEN
#            define APP_FULLSCREEN (0)
#        endif

#        ifndef YI_SIMULATE_TOUCH
#            define YI_SIMULATE_TOUCH (1)
#        endif

#if defined(YI_OSX)
#        import <Bugsnag/Bugsnag.h>
#endif

const float MILLIMETRES_PER_INCH = 25.4f;
#        define LOG_TAG "mainDefault"

std::unique_ptr<CYIApp> pApp; //You I Application class
GLFWwindow *pWindow = nullptr;
int forceDraws = 0; // Will set forceDirty to true if non zero during the Update() call, used when the window or framebuffer size changes.
int inputMultiplier = 1; // Save the previous input multiplier for input coordinate changes

#        ifdef YI_PROCESS_COMMAND_ARGS
void ProcessCommandArgs(int argc, char **argv);
#        else
void ProcessCommandArgs(int argc, char **argv)
{
    YI_UNUSED(argc);
    YI_UNUSED(argv);
}
#        endif

static CYIKeyEvent::KeyCode prevRepeatedKey = CYIKeyEvent::KeyCode::Unidentified; //used to determine if a char event is a result of a repeated key

static CYIKeyEvent::KeyCode GLFWkeyCodeToYIKeyCode(int32_t keyCode)
{
    switch (keyCode)
    {
        case GLFW_KEY_ESCAPE:
            return CYIKeyEvent::KeyCode::Escape;
        case GLFW_KEY_TAB:
            return CYIKeyEvent::KeyCode::Tab;
        case GLFW_KEY_LEFT_SHIFT:
        case GLFW_KEY_RIGHT_SHIFT:
            return CYIKeyEvent::KeyCode::Shift;
        case GLFW_KEY_LEFT_CONTROL:
        case GLFW_KEY_RIGHT_CONTROL:
            return CYIKeyEvent::KeyCode::Control;
        case GLFW_KEY_LEFT_ALT:
        case GLFW_KEY_RIGHT_ALT:
            return CYIKeyEvent::KeyCode::Alt;
        case GLFW_KEY_DELETE:
            return CYIKeyEvent::KeyCode::Delete;
        case GLFW_KEY_BACKSPACE:
            return CYIKeyEvent::KeyCode::Backspace;
        case GLFW_KEY_ENTER:
            return CYIKeyEvent::KeyCode::Enter;
        case GLFW_KEY_HOME:
            return CYIKeyEvent::KeyCode::Home;
        case GLFW_KEY_END:
            return CYIKeyEvent::KeyCode::End;
        case GLFW_KEY_PAGE_UP:
            return CYIKeyEvent::KeyCode::PageUp;
        case GLFW_KEY_PAGE_DOWN:
            return CYIKeyEvent::KeyCode::PageDown;
        case GLFW_KEY_INSERT:
            return CYIKeyEvent::KeyCode::Insert;
        case GLFW_KEY_LEFT:
            return CYIKeyEvent::KeyCode::ArrowLeft;
        case GLFW_KEY_RIGHT:
            return CYIKeyEvent::KeyCode::ArrowRight;
        case GLFW_KEY_DOWN:
            return CYIKeyEvent::KeyCode::ArrowDown;
        case GLFW_KEY_UP:
            return CYIKeyEvent::KeyCode::ArrowUp;
        case GLFW_KEY_F1:
            return CYIKeyEvent::KeyCode::F1;
        case GLFW_KEY_F2:
            return CYIKeyEvent::KeyCode::F2;
        case GLFW_KEY_F3:
            return CYIKeyEvent::KeyCode::F3;
        case GLFW_KEY_F4:
            return CYIKeyEvent::KeyCode::F4;
        case GLFW_KEY_F5:
            return CYIKeyEvent::KeyCode::F5;
        case GLFW_KEY_F6:
            return CYIKeyEvent::KeyCode::F6;
        case GLFW_KEY_F7:
            return CYIKeyEvent::KeyCode::F7;
        case GLFW_KEY_F8:
            return CYIKeyEvent::KeyCode::F8;
        case GLFW_KEY_F9:
            return CYIKeyEvent::KeyCode::F9;
        case GLFW_KEY_F10:
            return CYIKeyEvent::KeyCode::F10;
        case GLFW_KEY_F11:
            return CYIKeyEvent::KeyCode::F11;
        case GLFW_KEY_F12:
            return CYIKeyEvent::KeyCode::F12;
        case GLFW_KEY_F13:
            return CYIKeyEvent::KeyCode::F13;
        case GLFW_KEY_F14:
            return CYIKeyEvent::KeyCode::F14;
        case GLFW_KEY_F15:
            return CYIKeyEvent::KeyCode::F15;
        case GLFW_KEY_F16:
            return CYIKeyEvent::KeyCode::F16;
        case GLFW_KEY_F17:
            return CYIKeyEvent::KeyCode::F17;
        case GLFW_KEY_F18:
            return CYIKeyEvent::KeyCode::F18;
        case GLFW_KEY_F19:
            return CYIKeyEvent::KeyCode::F19;
        case GLFW_KEY_F20:
            return CYIKeyEvent::KeyCode::F20;
        case GLFW_KEY_F21:
            return CYIKeyEvent::KeyCode::F21;
        case GLFW_KEY_F22:
            return CYIKeyEvent::KeyCode::F22;
        case GLFW_KEY_F23:
            return CYIKeyEvent::KeyCode::F23;
        case GLFW_KEY_F24:
            return CYIKeyEvent::KeyCode::F24;
        case GLFW_KEY_UNKNOWN:
            return CYIKeyEvent::KeyCode::Unidentified;
        case GLFW_KEY_SPACE:
            return CYIKeyEvent::KeyCode::Space;

        case GLFW_KEY_KP_DIVIDE:
            return CYIKeyEvent::KeyCode::Divide;
        case GLFW_KEY_KP_MULTIPLY:
            return CYIKeyEvent::KeyCode::Multiply;
        case GLFW_KEY_KP_SUBTRACT:
            return CYIKeyEvent::KeyCode::Subtract;
        case GLFW_KEY_KP_ADD:
            return CYIKeyEvent::KeyCode::Add;
        case GLFW_KEY_KP_DECIMAL:
            return CYIKeyEvent::KeyCode::Decimal;
        case GLFW_KEY_KP_EQUAL:
            return CYIKeyEvent::KeyCode::Equal;
        case GLFW_KEY_KP_ENTER:
            return CYIKeyEvent::KeyCode::Enter;
        case GLFW_KEY_NUM_LOCK:
            return CYIKeyEvent::KeyCode::NumLock;
        case GLFW_KEY_CAPS_LOCK:
            return CYIKeyEvent::KeyCode::CapsLock;
        case GLFW_KEY_SCROLL_LOCK:
            return CYIKeyEvent::KeyCode::ScrollLock;
        case GLFW_KEY_PAUSE:
            return CYIKeyEvent::KeyCode::Pause;
        case GLFW_KEY_LEFT_SUPER:
        case GLFW_KEY_RIGHT_SUPER:
            return CYIKeyEvent::KeyCode::OperatingSystem;
    }

    // This is used to handle control characters in CharCallBack in OSX: we ignore all unicode code points that fall within the 'private use' area. The downside of this is that we won't be able to process control characters in KEY_INPUT event handlers.
    if (keyCode >= 0xE000 && keyCode <= 0xF8FF)
    {
        return CYIKeyEvent::KeyCode::Unidentified;
    }

    return CYIKeyEvent::KeyCode::Alphanumeric;
}

static void SetKeyEventAttributes(CYIKeyEvent &keyEvent, int32_t keyID, bool repeat)
{
    keyEvent.m_shiftKey = glfwGetKey(pWindow, GLFW_KEY_LEFT_SHIFT) || glfwGetKey(pWindow, GLFW_KEY_RIGHT_SHIFT) ? true : false;
    keyEvent.m_altKey = glfwGetKey(pWindow, GLFW_KEY_LEFT_ALT) || glfwGetKey(pWindow, GLFW_KEY_RIGHT_ALT) ? true : false;
    keyEvent.m_controlKey = glfwGetKey(pWindow, GLFW_KEY_LEFT_CONTROL) || glfwGetKey(pWindow, GLFW_KEY_RIGHT_CONTROL) ? true : false;
    keyEvent.m_metaKey = false;
    keyEvent.m_repeat = repeat;

    if (glfwGetKey(pWindow, GLFW_KEY_LEFT_ALT) ||
        glfwGetKey(pWindow, GLFW_KEY_LEFT_CONTROL) ||
        glfwGetKey(pWindow, GLFW_KEY_LEFT_SHIFT) ||
        glfwGetKey(pWindow, GLFW_KEY_LEFT_SUPER))
    {
        keyEvent.m_keyLocation = CYIKeyEvent::CYIKeyEvent::Location::Left;
    }
    else if (glfwGetKey(pWindow, GLFW_KEY_RIGHT_ALT) ||
             glfwGetKey(pWindow, GLFW_KEY_RIGHT_CONTROL) ||
             glfwGetKey(pWindow, GLFW_KEY_RIGHT_SHIFT) ||
             glfwGetKey(pWindow, GLFW_KEY_RIGHT_SUPER))
    {
        keyEvent.m_keyLocation = CYIKeyEvent::CYIKeyEvent::Location::Right;
    }
    else if ((keyID >= GLFW_KEY_KP_0 && keyID <= GLFW_KEY_KP_9) ||
             keyID == GLFW_KEY_KP_DIVIDE ||
             keyID == GLFW_KEY_KP_MULTIPLY ||
             keyID == GLFW_KEY_KP_SUBTRACT ||
             keyID == GLFW_KEY_KP_ADD ||
             keyID == GLFW_KEY_KP_DECIMAL ||
             keyID == GLFW_KEY_KP_EQUAL ||
             keyID == GLFW_KEY_KP_ENTER ||
             keyID == GLFW_KEY_NUM_LOCK)
    {
        keyEvent.m_keyLocation = CYIKeyEvent::CYIKeyEvent::Location::NumPad;
    }
    else
    {
        keyEvent.m_keyLocation = CYIKeyEvent::CYIKeyEvent::Location::Standard;
    }
}

void CharCallback(GLFWwindow *pWindow, uint32_t unicode)
{
    YI_UNUSED(pWindow);

    if (pApp)
    {
        CYIEvent::Type eventType = CYIEvent::Type::KeyInput;
        CYIKeyEvent keyEvent(eventType);
        keyEvent.m_keyValue = (char32_t)unicode;
        keyEvent.m_keyCode = GLFWkeyCodeToYIKeyCode(unicode);

        bool repeat = false;
        if (prevRepeatedKey == keyEvent.m_keyCode && keyEvent.m_keyCode != CYIKeyEvent::KeyCode::Unidentified)
        {
            repeat = true;
        }
        SetKeyEventAttributes(keyEvent, 0, repeat);
        pApp->HandleKeyInputs(keyEvent);
    }
}

void KeyCallback(GLFWwindow *pWindow, int32_t keyID, int32_t scanCode, int32_t action, int32_t mods)
{
    YI_UNUSED(pWindow);
    YI_UNUSED(scanCode);
    YI_UNUSED(mods);

    if (pApp)
    {
        CYIKeyEvent::KeyCode controlKey = GLFWkeyCodeToYIKeyCode(keyID);
        CYIEvent::Type eventType = action == GLFW_PRESS || action == GLFW_REPEAT ? CYIEvent::Type::KeyDown : CYIEvent::Type::KeyUp;
        CYIKeyEvent keyEvent(eventType);
        keyEvent.m_keyCode = controlKey;
        const bool repeat = action == GLFW_REPEAT;
        SetKeyEventAttributes(keyEvent, keyID, repeat);
        if (repeat)
        {
            prevRepeatedKey = keyEvent.m_keyCode;
        }
        else
        {
            prevRepeatedKey = CYIKeyEvent::KeyCode::Unidentified;
        }
        keyEvent.m_keyValue = (char32_t)keyID;
        pApp->HandleKeyInputs(keyEvent);
    }
}

void MousePosCallback(GLFWwindow *pWindow, double x, double y)
{
    YI_UNUSED(pWindow);

    if (pApp)
    {
        CYIActionEvent::ButtonType mouseButton = CYIActionEvent::ButtonType::None;
        if (glfwGetMouseButton(pWindow, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
        {
            mouseButton = CYIActionEvent::ButtonType::Left;
        }
        else if (glfwGetMouseButton(pWindow, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS)
        {
            mouseButton = CYIActionEvent::ButtonType::Right;
        }
        else if (glfwGetMouseButton(pWindow, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS)
        {
            mouseButton = CYIActionEvent::ButtonType::Middle;
        }

        CYIEvent::Type eventType = CYIEvent::Type::ActionMove;
        bool hover = YI_SIMULATE_TOUCH ? false : true;

        if (YI_SIMULATE_TOUCH && mouseButton == CYIActionEvent::ButtonType::None)
        {
            eventType = CYIEvent::Type::ActionSuppressedMove;
        }

        pApp->HandleActionInputs(static_cast<int32_t>(x) * inputMultiplier, static_cast<int32_t>(y) * inputMultiplier, 0, mouseButton, eventType, 0, hover);
    }
}

void MouseButtonCallback(GLFWwindow *pWindow, int32_t mouseButtonID, int32_t action, int32_t mods)
{
    YI_UNUSED(pWindow);
    YI_UNUSED(mods);

    if (pApp)
    {
        double x, y;
        glfwGetCursorPos(pWindow, &x, &y);
        bool hover = YI_SIMULATE_TOUCH ? false : true;

        bool actionIsPress = action == GLFW_PRESS;
        pApp->HandleActionInputs(static_cast<int32_t>(x) * inputMultiplier, static_cast<int32_t>(y) * inputMultiplier,
                                 0, (CYIActionEvent::ButtonType)mouseButtonID, actionIsPress ? CYIEvent::Type::ActionDown : CYIEvent::Type::ActionUp, 0, hover);
    }
}

void MouseWheelCallback(GLFWwindow *pWindow, double xOffset, double yOffset)
{
    YI_UNUSED(pWindow);

    if (pApp)
    {
        double x, y;
        glfwGetCursorPos(pWindow, &x, &y);

        if (!glm::epsilonEqual(xOffset, 0.0, glm::epsilon<double>()))
        {
            pApp->HandleActionInputs(static_cast<int32_t>(x) * inputMultiplier, static_cast<int32_t>(y) * inputMultiplier, static_cast<int32_t>(xOffset), CYIActionEvent::ButtonType::None, CYIEvent::Type::ActionWheelHorizontal, 0, true);
        }
        if (!glm::epsilonEqual(yOffset, 0.0, glm::epsilon<double>()))
        {
            pApp->HandleActionInputs(static_cast<int32_t>(x) * inputMultiplier, static_cast<int32_t>(y) * inputMultiplier, static_cast<int32_t>(yOffset), CYIActionEvent::ButtonType::None, CYIEvent::Type::ActionWheelVertical, 0, true);
        }

        pApp->HandleActionInputs(static_cast<int32_t>(x) * inputMultiplier, static_cast<int32_t>(y) * inputMultiplier, static_cast<int32_t>((glm::abs(xOffset) > glm::abs(yOffset)) ? (xOffset) : (yOffset)), CYIActionEvent::ButtonType::None, CYIEvent::Type::ActionWheel, 0, true);
    }
}

glm::vec2 GetScreenDensity()
{
    GLFWmonitor *pMonitor = glfwGetPrimaryMonitor();
    if (pMonitor)
    {
        const GLFWvidmode *pMode = glfwGetVideoMode(pMonitor);
        int widthMillimetres, heightMillimetres;
        glfwGetMonitorPhysicalSize(pMonitor, &widthMillimetres, &heightMillimetres);
        double dPIWdith = pMode->width / (widthMillimetres / MILLIMETRES_PER_INCH);
        double dPIHeight = pMode->height / (heightMillimetres / MILLIMETRES_PER_INCH);

        return glm::vec2(dPIWdith, dPIHeight);
    }
    // Use default 72 dpi when running with null renderer in headless mode
    return glm::vec2(72, 72);
}

void WindowFrameSizeChange()
{
    int32_t windowWidth = 0, windowHeight = 0, surfaceWidth = 0, surfaceHeight = 0;
    glfwGetWindowSize(pWindow, &windowWidth, &windowHeight);
    glfwGetFramebufferSize(pWindow, &surfaceWidth, &surfaceHeight);

    auto multiplier = surfaceWidth / windowWidth;
    const glm::vec2 DPI = GetScreenDensity();

    if (pApp)
    {
        CYISurface *pSurface = CYIAppContext::GetInstance()->GetSurface();
        CYIScreen *pScreen = CYIAppContext::GetInstance()->GetScreen();
        if (pScreen->GetWidthPixels() != windowWidth ||
            pScreen->GetHeightPixels() != windowHeight ||
            pSurface->GetWidth() != surfaceWidth ||
            pSurface->GetHeight() != surfaceHeight ||
            inputMultiplier != multiplier)
        {
            YI_LOGD("MainDefault", "WindowFrameSizeChange window %dx%d to %dx%d.",
                    pScreen->GetWidthPixels(), pScreen->GetHeightPixels(), windowWidth, windowHeight);
            YI_LOGD("MainDefault", "WindowFrameSizeChange surface %dx%d to %dx%d.",
                    pSurface->GetWidth(), pSurface->GetHeight(), surfaceWidth, surfaceHeight);

            inputMultiplier = multiplier;
            pApp->SetScreenProperties(windowWidth,
                                      windowHeight,
                                      static_cast<int>(DPI.x) * inputMultiplier,
                                      static_cast<int>(DPI.y) * inputMultiplier);
            pApp->SurfaceWasResized(surfaceWidth, surfaceHeight);

            // We must force a redraw twice in a row, because if both window and surface size changes in the same frame the scene will not be correctly re-rendered.
            forceDraws = 2;
        }
    }
}

void WindowSizeCallback(GLFWwindow * /*pWindow*/, int32_t /*width*/, int32_t /*height*/)
{
    // This callback is used for window size and frame size, as this ignores all the state, and just polls glfw for the information anyways. This is done to avoid sending our app multiple calls with the same size, as normal flow is a WindowSizeCallback followed by a FrameBufferCallback. Sometimes these are the same size though, and don't result in changes.
    WindowFrameSizeChange();
}

static CYIString GetExecutableDir()
{
    CYIString path = "." + CYIDir::GetSeparator();

#        if defined(YI_LINUX)

    {
        char executablePath[YI_MAX_PATH];
        const ssize_t executablePathLength = readlink("/proc/self/exe", executablePath, sizeof(executablePath) - 1);
        if (0 < executablePathLength)
        {
            executablePath[executablePathLength] = '\0';
            path = CYIFile::ExtractParentFromPath(executablePath);
        }
        else
        {
            YI_LOGW("MainDefault", "Could not get executable directory");
        }
    }

#        elif defined(YI_OSX)

    // On OSX, the current working directory of an application when run from 'Finder' is NOT the directory that the app is in. We need to find what that path is in order to access the assets.
    char pExecutablePath[YI_MAX_PATH];
    uint32_t size = static_cast<uint32_t>(sizeof(pExecutablePath));
    if (_NSGetExecutablePath(pExecutablePath, &size) == 0)
    {
        char pLinkPath[YI_MAX_PATH];
        if (realpath(pExecutablePath, pLinkPath) != 0)
        {
            const CYIString executablePath = CYIFile::ExtractParentFromPath(pLinkPath);
            path = executablePath;
        }
    }

#        elif defined(YI_WIN32)
    WCHAR curDir[YI_MAX_PATH + 1];
    DWORD retVal = GetModuleFileNameW(NULL, curDir, MAX_PATH);
    if (retVal != 0 || retVal != YI_MAX_PATH)
    {
        path = CYIFile::ExtractParentFromPath(curDir);
    }
    else
    {
        YI_LOGW("MainDefault", "Could not get executable directory");
    }
#        endif

    return path;
}

int main(int argc, char *argv[])
{
    CYILogger::Initialize();

    std::unique_ptr<CYISurface> pSurface;
    bool Running = true; //Flag for running state
    CYISurface::Config surfaceConfig;
    YI_MEMSET(&surfaceConfig, 0, sizeof(surfaceConfig));
    surfaceConfig.width = AppFactory::GetWindowWidth();
    surfaceConfig.height = AppFactory::GetWindowHeight();

    // override display resolution with parameters provided through the command line
    //int opt=0;
    //while ((opt = getopt(argc, argv, "f:w:h:s:")) != -1)
    //{
    //    switch (opt)
    //    {
    //    case 'f':
    //        surfaceConfig.fullScreen = opt;
    //        break;
    //    case 'w':
    //        surfaceConfig.width = opt;
    //        break;
    //    case 'h':
    //        surfaceConfig.height = opt;
    //        break;
    //    default:
    //        std::cerr << "Error with this arg!" << std::endl;
    //        break;
    //    }
    //}

    pSurface = CYISurface::New(&surfaceConfig, CYISurface::WindowOwnership::OwnsWindow);
    if (!pSurface)
    {
        return 1;
    }

    pWindow = reinterpret_cast<GLFWwindow *>(pSurface->GetContext());

    ProcessCommandArgs(argc, argv);

    pApp = AppFactory::Create();
    if (pApp == nullptr)
    {
        return 1;
    }
    CYIString path = GetExecutableDir();
    pApp->SetAssetsPath(path + "assets/");
    pApp->SetDataPath(path);
    pApp->SetExternalPath(path);

    int32_t winWidth = 0, winHeight = 0, frameWidth = 0, frameHeight = 0;
    glfwGetWindowSize(pWindow, &winWidth, &winHeight);
    glfwGetFramebufferSize(pWindow, &frameWidth, &frameHeight);
    inputMultiplier = frameWidth / winWidth;

    const glm::vec2 DPI = GetScreenDensity();
    pApp->SetScreenProperties(winWidth, winHeight,
                              static_cast<int>(DPI.x) * inputMultiplier,
                              static_cast<int>(DPI.y) * inputMultiplier);
    pSurface->SurfaceWasResized(frameWidth, frameHeight);
    pApp->SetSurface(pSurface.get());

    // Main application init
    if (!pApp->Init())
    {
        pApp.reset();
        pSurface.reset();
        return 1;
    }

    glfwSetWindowTitle(pWindow, AppFactory::GetWindowName());
    glfwSetInputMode(pWindow, GLFW_STICKY_KEYS, GLFW_TRUE); // Tell GLFW to report key repeats when a key is held down

    // Configure the Keyboard and Mouse Input callbacks

    glfwSetCharCallback(pWindow, &CharCallback);
    glfwSetKeyCallback(pWindow, &KeyCallback);
    glfwSetCursorPosCallback(pWindow, &MousePosCallback);
    glfwSetMouseButtonCallback(pWindow, &MouseButtonCallback);
    glfwSetScrollCallback(pWindow, &MouseWheelCallback);
    glfwSetWindowSizeCallback(pWindow, &WindowSizeCallback);
    glfwSetFramebufferSizeCallback(pWindow, &WindowSizeCallback);

#if defined(YI_OSX)
    [Bugsnag startBugsnagWithApiKey:@"e8fec3c046d6d0eed80c60d4d30690a2"];
    [Bugsnag notifyError: [[NSError alloc] initWithDomain:@"tv.youi" code:408 userInfo:nil]];
#endif

    while (Running)
    {
        // poll input events
        glfwPollEvents();

        pApp->Update(forceDraws > 0);
        pApp->Draw();
        pApp->Swap();
        if (forceDraws)
        {
            forceDraws--;
        }
        Running = glfwWindowShouldClose(pWindow) == GLFW_FALSE;
    }

    // detach user inputs callbacks
    glfwSetCharCallback(pWindow, nullptr);
    glfwSetKeyCallback(pWindow, nullptr);
    glfwSetCursorPosCallback(pWindow, nullptr);
    glfwSetMouseButtonCallback(pWindow, nullptr);
    glfwSetScrollCallback(pWindow, nullptr);
    glfwSetWindowSizeCallback(pWindow, nullptr);
    glfwSetFramebufferSizeCallback(pWindow, nullptr);

    pApp.reset();
    pSurface.reset();
    return 0;
}

#    endif
#endif
