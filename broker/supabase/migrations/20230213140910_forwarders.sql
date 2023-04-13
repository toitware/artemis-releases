-- Copyright (C) 2023 Toitware ApS.
-- Use of this source code is governed by an MIT-style license that can be
-- found in the LICENSE file.

-------------------------------------------------------
-- Expose the functions through Postgrest by having forwarders in the public schema.

SET search_path TO public;

CREATE OR REPLACE FUNCTION public."toit_artemis.new_provisioned"(_device_id UUID, _state JSONB)
RETURNS VOID
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM toit_artemis.new_provisioned(_device_id, _state);
END;
$$;

CREATE OR REPLACE FUNCTION public."toit_artemis.update_state"(_device_id UUID, _state JSONB)
RETURNS VOID
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM toit_artemis.update_state(_device_id, _state);
END;
$$;

CREATE OR REPLACE FUNCTION public."toit_artemis.get_goal"(_device_id UUID)
RETURNS JSON
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT toit_artemis.get_goal(_device_id));
END;
$$;

CREATE OR REPLACE FUNCTION public."toit_artemis.get_state"(_device_id UUID)
RETURNS JSON
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT toit_artemis.get_state(_device_id));
END;
$$;

CREATE OR REPLACE FUNCTION public."toit_artemis.set_goal"(_device_id UUID, _goal JSONB)
RETURNS VOID
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM toit_artemis.set_goal(_device_id, _goal);
END;
$$;

CREATE OR REPLACE FUNCTION public."toit_artemis.remove_device"(_device_id UUID)
RETURNS VOID
SECURITY INVOKER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM toit_artemis.remove_device(_device_id);
END;
$$;
