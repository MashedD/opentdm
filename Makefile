### OpenTDM Makefile ###
#
# Native Linux build:          make
# Windows cross build (MinGW): make CONFIG_FILE=.config-win64
#                              make CONFIG_FILE=.config-win32
# Without libcurl:             make USE_CURL=0
# Show full commands:          make V=1
#
# See ./build.sh for a wrapper that also builds libcurl for Windows.

ifdef CONFIG_FILE
    include $(CONFIG_FILE)
else
    -include .config
endif

# Toolchain prefix, such as x86_64-w64-mingw32- for cross builds.
CROSS ?=

ifeq ($(origin CC),default)
    CC := $(CROSS)gcc
endif
WINDRES ?= $(CROSS)windres
STRIP ?= $(CROSS)strip
PKG_CONFIG ?= pkg-config
RM ?= rm -f

# Detect the target from the compiler, so cross builds get the right names.
MACHINE := $(shell $(CC) -dumpmachine)

ifneq ($(findstring mingw,$(MACHINE)),)
    CONFIG_WINDOWS ?= 1
endif

ifndef CPU
    ifdef CONFIG_32BIT
        CPU := x86
    else
        CPU := $(shell echo $(MACHINE) | cut -d- -f1 | sed -e s/i.86/x86/ -e s/amd64/x86_64/ -e s/arm64/aarch64/ -e s/arm.*/arm/)
    endif
endif

ifndef REV
    REV := $(shell git rev-list --count HEAD 2>/dev/null || echo 0)
endif

ifndef VER
    VER := r$(REV)~$(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
endif

CFLAGS ?= -O2 -g
CFLAGS += -std=gnu99 -fno-strict-aliasing -Wall -Wno-unused-but-set-variable
CPPFLAGS += -MMD -MP -DC_ONLY
CPPFLAGS += -DOPENTDM_VERSION='"$(VER)"' -DOPENTDM_REVISION=$(REV)
RCFLAGS += -DOPENTDM_VERSION='\"$(VER)\"' -DOPENTDM_REVISION=$(REV)
LDFLAGS += -shared
LIBS ?=

ifdef CONFIG_32BIT
    ifndef CONFIG_WINDOWS
        CFLAGS += -m32
        LDFLAGS += -m32
    endif
endif

# libcurl is used for downloading remote configs and sending match stats.
# Linux links against the system libcurl; Windows links a static libcurl,
# which ./build.sh builds and points PKG_CONFIG_PATH at.
USE_CURL ?= 1
ifeq ($(USE_CURL),1)
    ifdef CONFIG_WINDOWS
        CURL_PKG_FLAGS ?= --static
    endif
    CURL_CFLAGS ?= $(shell $(PKG_CONFIG) $(CURL_PKG_FLAGS) --cflags libcurl)
    CURL_LIBS ?= $(shell $(PKG_CONFIG) $(CURL_PKG_FLAGS) --libs libcurl)
    ifeq ($(strip $(CURL_LIBS)),)
        $(error libcurl not found by $(PKG_CONFIG); install it, set CURL_CFLAGS/CURL_LIBS, or build with USE_CURL=0)
    endif
    CPPFLAGS += -DHAVE_CURL $(CURL_CFLAGS)
    LIBS += $(CURL_LIBS)
endif

SRCS := g_chase.c g_cmds.c g_combat.c g_func.c g_items.c g_main.c g_misc.c \
    g_net.c g_phys.c g_save.c g_spawn.c g_svcmds.c g_target.c g_tdm_client.c \
    g_tdm_cmds.c g_tdm_core.c g_tdm_curl.c g_tdm_macros.c g_tdm_stats.c \
    g_tdm_vote.c g_tdm_votemenu.c g_trigger.c g_utils.c g_weapon.c md5.c mt19937.c \
    p_client.c p_hud.c p_menu.c p_view.c p_weapon.c q_shared.c

ifdef CONFIG_WINDOWS
    SRCS += sys_win32.c
    RCSRCS := opentdm.rc
    CPPFLAGS += -DWIN32 -D_WIN32_WINNT=0x0601
    LDFLAGS += -static -static-libgcc -Wl,--nxcompat,--dynamicbase
    LIBS += -lws2_32
    TARGET ?= game$(CPU).dll
else
    SRCS += sys_linux.c
    RCSRCS :=
    CFLAGS += -fPIC -fvisibility=hidden
    LDFLAGS += -Wl,--no-undefined
    LIBS += -lm
    TARGET ?= game$(CPU).so
endif

BUILDDIR ?= build/$(basename $(TARGET))-$(MACHINE)
OBJS := $(SRCS:%.c=$(BUILDDIR)/%.o) $(RCSRCS:%.rc=$(BUILDDIR)/%.o)

# Define V=1 to show command lines.
ifdef V
    Q :=
    E := @true
else
    Q := @
    E := @echo
endif

.PHONY: all default clean strip

default: all
all: $(TARGET)

-include $(OBJS:.o=.d)

$(BUILDDIR):
	$(Q)mkdir -p $@

$(BUILDDIR)/%.o: %.c | $(BUILDDIR)
	$(E) [CC] $<
	$(Q)$(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: %.rc | $(BUILDDIR)
	$(E) [RC] $<
	$(Q)$(WINDRES) $(RCFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(E) [LD] $@
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	$(E) [CLEAN] $(TARGET)
	$(Q)$(RM) -r $(BUILDDIR) $(TARGET)

strip: $(TARGET)
	$(E) [STRIP] $(TARGET)
	$(Q)$(STRIP) $(TARGET)
