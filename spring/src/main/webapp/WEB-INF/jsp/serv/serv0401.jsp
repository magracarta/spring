<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 담당별 장비관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-23 17:35:30
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;
        var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            fnInit();
        });

        function fnInit() {
            <%--var now = "${inputParam.s_current_dt}";--%>
            <%--$M.setValue("s_start_dt", "19920101");--%>
            <%--$M.setValue("s_end_dt", now);--%>

            var obj = $("#s_center_org_code");
            goSearchCenterOrgMem(obj[0]);

            <%--var orgType = "${SecureUser.org_type}";--%>
            <%--var memNo = "${SecureUser.mem_no}";--%>

            // 2022.07.07 김상덕
            // mem_no 선규원 -> 염성민으로 수정.
            // 업무권한이 워렌티업무 이면 적용되는것으로 잘못 알고계셔서 3차 개선사항으로 추가예정.
            // if (orgType == "CENTER" && memNo != "MB00001193") {
            if(${page.fnc.F00770_001 ne 'Y'}) {
                $("#s_center_org_code").prop("disabled", true);
            }

            // 페이지 진입 시, 조회기간 세팅전에 조회되는 현상 수정
            setTimeout(function() {
                goSearch();
            }, 500);
        }

        // 펼침
        function fnChangeColumn(event) {
            var data = AUIGrid.getGridData(auiGrid);
            var target = event.target || event.srcElement;
            if (!target) return;

            var dataField = target.value;
            var checked = target.checked;

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];

                if (checked) {
                    AUIGrid.showColumnByDataField(auiGrid, dataField);
                } else {
                    AUIGrid.hideColumnByDataField(auiGrid, dataField);
                }
            }
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                // 체크박스 출력 여부
                showRowCheckColumn: true,
                // 전체선택 체크박스 표시 여부
                showRowAllCheckBox: true,
                // 전체 선택 체크박스가 독립적인 역할을 할지 여부
                independentAllCheckBox: true,
                enableFilter: true,
                // 고정칼럼 카운트 지정
                // fixedColumnCount : 10,
                rowStyleFunction : function(rowIndex, item) {
                    if(item.extend_target_yn == "Y") {
                        return "aui-privacy_extend_target";
                    }
                    return "";
                }
            };
            var columnLayout = [
                {
                    headerText: "담당센터",
                    dataField: "center_org_name",
                    headerStyle: "aui-fold",
                    width: "100",
                    minWidth: "90",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "지역명",
                    dataField: "area_disp",
                    width: "90",
                    minWidth: "80",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "마케팅담당",
                    dataField: "sale_mem_name",
                    headerStyle: "aui-fold",
                    width: "80",
                    minWidth: "70",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "서비스담당",
                    dataField: "service_mem_name",
                    headerStyle: "aui-fold",
                    width: "80",
                    minWidth: "70",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width: "150",
                    minWidth: "140",
                    style: "aui-center aui-popup",
                    filter: {
                        showIcon: true
                    }
                },
                // 21.09.02 (SR : 12408) 고객분류 컬럼 추가
                {
                    headerText: "고객분류",
                    dataField: "cust_sale_type_name",
                    width: "70",
                    minWidth: "60",
                    style: "aui-center",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    dataField: "real_cust_name",
                    visible: false
                },
                {
                    dataField: "cust_no",
                    visible: false
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width: "150",
                    minWidth: "140",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width: "150",
                    minWidth: "140",
                    style: "aui-center aui-popup",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "장비구분",
                    dataField: "mch_op_type_name",
                    width: "70",
                    minWidth: "60",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "장비용도",
                    dataField: "mch_use_name",
                    width: "120",
                    minWidth: "60",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "휴대폰",
                    dataField: "hp_no",
                    width: "100",
                    minWidth: "100",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    dataField: "real_hp_no",
                    visible: false
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    width: "70",
                    minWidth: "60",
                    dataType: "date",
                    style: "aui-center",
                    formatString: "yy-mm-dd",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "최근<br>가동시간",
                    dataField: "op_hour",
                    width: "70",
                    minWidth: "60",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
                },
                {
                    headerText: "최근정비일",
                    // dataField: "last_job_report_dt",
                    dataField: "last_as_repair_dt", // 23.12.22 최근정비지시서일자에서 최근정비일자로 변경
                    style: "aui-center aui-popup",
                    width: "90",
                    minWidth: "60",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "정비율",
                    dataField: "maintenance_rate",
                    style: "aui-center",
                    width: "60",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return Math.round(value) + "%";
                    },
                },
                {
                    headerText: "당기<br>가동시간",
                    dataField: "run_time",
                    style: "aui-center",
                    width: "60",
                    dataType : "numeric",
				    formatString : "#,###",
                },
                {
                    headerText: "총<br>정비건수",
                    dataField: "total_repair_cnt",
                    width: "70",
                    minWidth: "60",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 ? "" : $M.setComma(value);
                    },
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "당년<br>정비건수",
                    dataField: "repair_cnt_this_year",
                    width: "60",
                    dataType : "numeric",
                    formatString: "#,###",
                },
                {
                    headerText: "캠페인대상",
                    dataField: "campaign_machine_yn",
                    headerStyle: "aui-fold",
                    width: "90",
                    minWidth: "60",
                    style: "aui-center aui-popup",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    dataField: "campaign_seq",
                    visible: false
                },
                {
					headerText: "가동시간(SA-R)",
					headerStyle : "aui-fold",
					dataField: "sar_op_hour",
					width : "110",
					minWidth : "100",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value > 0) {
							return value + " h"
						} else {
							return "";
						}
					}
				},
                {
                    headerText: "평균가동시간",
                    dataField: "month_op_hour",
                    headerStyle: "aui-fold",
                    children: [
                        {
                            dataField: "mon_avr_1_hour",
                            headerText: "1개월",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? "" : $M.setComma(value);
                            }
                        },
                        {
                            dataField: "mon_avr_3_hour",
                            headerText: "3개월",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? "" : $M.setComma(value);
                            }
                        },
                        {
                            dataField: "mon_avr_6_hour",
                            headerText: "6개월",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? "" : $M.setComma(value);
                            }
                        },
                        {
                            dataField: "mon_avr_12_hour",
                            headerText: "12개월",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return value == 0 ? "" : $M.setComma(value);
                            }
                        },
                    ]
                },
                {
                    headerText: "순회 정비<br>예정일",
                    dataField: "next_trip_dt",
                    dataType: "date",
                    style: "aui-center",
                    formatString: "yy-mm-dd",
                    width: "70",
                    minWidth: "60"
                },
                {
                    headerText: "점검",
                    headerStyle: "aui-fold",
                    children: [
                        {
                            dataField: "di_call_dt",
                            headerText: "DI",
                            dataType: "date",
                            style: "aui-center",
                            formatString: "yy-mm-dd",
                            headerStyle: "aui-fold",
                            width: "70",
                            minWidth: "60",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "ft_call_dt",
                            headerText: "초기",
                            dataType: "date",
                            style: "aui-center",
                            formatString: "yy-mm-dd",
                            headerStyle: "aui-fold",
                            width: "70",
                            minWidth: "60",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "ed_call_dt",
                            headerText: "종료",
                            dataType: "date",
                            style: "aui-center",
                            formatString: "yy-mm-dd",
                            headerStyle: "aui-fold",
                            width: "70",
                            minWidth: "60",
                            filter: {
                                showIcon: true
                            }
                        },
                    ]
                },
                {
                    headerText: "개인정보동의",
                    headerStyle: "aui-fold",
                    children: [
                        {
                            dataField: "cust_privacy_p",
                            headerText: "수집",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "cust_privacy_t",
                            headerText: "제3자",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "cust_privacy_m",
                            headerText: "마케팅",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            filter: {
                                showIcon: true
                            }
                        }
                    ]
                },
                {
                    headerText: "CAP",
                    headerStyle: "aui-fold",
                    children: [
                        {
                            dataField: "cap_yn",
                            headerText: "적용",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "cap_cnt",
                            headerText: "회차",
                            headerStyle: "aui-fold",
                            width: "60",
                            minWidth: "50",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                return item.cap_yn == "N" ? "" : item.cap_cnt;
                            },
                            filter: {
                                showIcon: true
                            }
                        },
                        {

                            dataField: "job_ed_dt",
                            headerText: "정비일자",
                            headerStyle: "aui-fold",
                            dataType: "date",
                            style: "aui-center",
                            formatString: "yy-mm-dd",
                            width: "70",
                            minWidth: "60",
                            filter: {
                                showIcon: true
                            }
                        },
                        {
                            dataField: "plan_dt",
                            headerText: "예정일자",
                            headerStyle: "aui-fold",
                            dataType: "date",
                            style: "aui-center",
                            formatString: "yy-mm-dd",
                            width: "70",
                            minWidth: "60",
                            filter: {
                                showIcon: true
                            }
                        },
                    ]
                },
                {
                    headerText: "주소",
                    dataField: "addr",
                    headerStyle: "aui-fold",
                    style: "aui-left",
                    width: "460",
                    minWidth: "100",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    headerText: "앱사용여부",
                    dataField: "app_use_yn",
                    style: "aui-center",
                    width: "80",
                    minWidth: "60",
                    filter: {
                        showIcon: true
                    }
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "cust_name") {
                    var param = {
                        cust_no: event.item.cust_no
                    };
                    var popupOption = "";
                    $M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus: popupOption});
                }

                // if (event.dataField == "last_job_report_dt") {
                if (event.dataField == "last_as_repair_dt") {
                    var param = {
                        s_machine_seq: event.item.machine_seq
                    };
                    var popupOption = "";
                    $M.goNextPage('/comp/comp0506', $M.toGetParam(param), {popupStatus: popupOption});
                }

                if (event.dataField == "body_no") {
                    var param = {
                        s_machine_seq: event.item.machine_seq
                    };
                    var popupOption = "";
                    $M.goNextPage('/sale/sale0205p01', $M.toGetParam(param), {popupStatus: popupOption});
                }

                if (event.dataField == "campaign_machine_yn") {
                    if (event.item.campaign_seq == '') {
                        alert("캠페인 대상장비가 아닙니다.");
                        return;
                    } else {
                        var popupOption = "";
                        var param = {
                            campaign_seq: event.item.campaign_seq
                        };

                        $M.goNextPage('/serv/serv0506p01', $M.toGetParam(param), {popupStatus: popupOption});
                    }
                }
            });


            // 전체 체크박스 클릭 이벤트 바인딩
            AUIGrid.bind(auiGrid, "rowAllChkClick", function (event) {
                if (event.checked) {
                    var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "machine_seq");
                    AUIGrid.setCheckedRowsByValue(event.pid, "machine_seq", uniqueValues);
                } else {
                    AUIGrid.setCheckedRowsByValue(event.pid, "machine_seq", []);
                }
            });

            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

            // 펼치기 전에 접힐 컬럼 목록
            var auiColList = AUIGrid.getColumnInfoList(auiGrid);
            for (var i = 0; i < auiColList.length; ++i) {
                if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                    dataFieldName.push(auiColList[i].dataField);
                }
            }

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];
                AUIGrid.hideColumnByDataField(auiGrid, dataField);
            }
        }

        function goSearch() {
            // 조회 버튼 눌렀을경우 1페이지로 초기화
            page = 1;
            moreFlag = "N";
            fnSearch(function (result) {
                AUIGrid.setGridData(auiGrid, result.list);
                $("#total_cnt").html(result.total_cnt);
                $("#curr_cnt").html(result.list.length);
                if (result.more_yn == 'Y') {
                    moreFlag = "Y";
                    page++;
                }
            });
        }

        // 조회
        function fnSearch(successFunc) {
            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            }

            var optimeYn = $M.getValue("optime_yn");
            var startOptime = "";
            var endOptime = "";
            var optimePeriod = "";

            if (optimeYn == "Y") {
                startOptime = $M.getValue("s_start_optime");
                endOptime = $M.getValue("s_end_optime");
                optimePeriod = $M.getValue("s_optime_period");

                if (startOptime != "" && endOptime != "") {
                    if (Number(startOptime) >= Number(endOptime)) {
                        alert("입력시간(이상)은 입력시간(이하) 보다 작아야합니다.");
                        return;
                    }
                }
            }

            var param = {

                s_start_dt: $M.getValue("s_start_dt"),
                s_end_dt: $M.getValue("s_end_dt"),
//                 s_maker_cd: $M.getValue("s_maker_cd"),
                s_maker_cd_str: $M.getValue("s_maker_cd_str"),  // 21.08.03 (SR:12007) 메이커 다중조회 추가 - 황빛찬
                s_machine_name: $M.getValue("s_machine_name"), 			//모델명
                s_center_org_code: $M.getValue("s_center_org_code"), 		//센터
                s_center_mem_no: $M.getValue("s_center_mem_no"),			//센터담당자
                s_include_stop_yn: $M.getValue("s_include_stop_yn"), 		// 거래정지품목포함
                s_cap_yn: $M.getValue("s_cap_yn"), 						// CAP
                s_except_yk_yn: $M.getValue("s_except_yk_yn"), 			// YK건기제외
                s_except_used_yn: $M.getValue("s_except_used_yn"), 		// 중고장비제외
                s_except_rental_yn: $M.getValue("s_except_rental_yn"), 	// 렌탈장비제외
                s_except_agency_yn: $M.getValue("s_except_agency_yn"), 	// 렌탈장비제외
                s_campaign_yn: $M.getValue("s_campaign_yn"), 				// 캠페인대상
                s_start_optime: startOptime,
                s_end_optime: endOptime,
                s_optime_period: optimePeriod,
                s_extend_target_yn : $M.getValue("s_extend_target_yn"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                s_sort_key: "sale_dt",
                s_sort_method: "desc",
                "page": page,
                "rows": $M.getValue("s_rows")
            }
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            console.log(param);
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                    }
                }
            );
        }

        // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
        function fnScollChangeHandelr(event) {
            if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                goMoreData();
            }
        }

        function goMoreData() {
            fnSearch(function (result) {
                result.more_yn == "N" ? moreFlag = "N" : page++;
                if (result.list.length > 0) {
                    console.log(result.list);
                    AUIGrid.appendData("#auiGrid", result.list);
                    $("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
                }
            });
        }

        function goSearchCenterOrgMem(obj) {
            $("select#s_center_mem_no option").remove();
            $('#s_center_mem_no').append('<option value="" >' + "- 전체 -" + '</option>');

            if (obj.value != "") {

                //센터담당자 초기화 및 세팅
                $M.goNextPageAjax(this_page + "/searchCenterOrgMem" + "/" + obj.value, "", {
                        method: "get",
                        loader: false
                    },
                    function (result) {
                        if (result.memList != "" && result.memList != undefined) {
                            for (i = 0; i < result.memList.length; i++) {
                                var optVal = result.memList[i].mem_no;
                                var optText = result.memList[i].mem_name;
                                $('#s_center_mem_no').append('<option value="' + optVal + '">' + optText + '</option>');
                            }

                        }
                    }
                );
            }
        }


        // 구분변경
        function fnChangeGubun() {

            var s_include_stop_yn = $M.getValue("s_include_stop_yn");
            var s_cap_yn = $M.getValue("s_cap_yn");
            var s_except_yk_yn = $M.getValue("s_except_yk_yn");
            var s_except_used_yn = $M.getValue("s_except_used_yn");
            var s_except_rental_yn = $M.getValue("s_except_rental_yn");
            var s_except_agency_yn = $M.getValue("s_except_agency_yn");
            var s_campaign_yn = $M.getValue("s_campaign_yn");

            $M.setValue("s_include_stop_yn", (s_include_stop_yn == "Y") ? s_include_stop_yn : "N");
            $M.setValue("s_cap_yn", (s_cap_yn == "Y") ? s_cap_yn : "N");
            $M.setValue("s_except_yk_yn", (s_except_yk_yn == "Y") ? s_except_yk_yn : "N");
            $M.setValue("s_except_used_yn", (s_except_used_yn == "Y") ? s_except_used_yn : "N");
            $M.setValue("s_except_rental_yn", (s_except_rental_yn == "Y") ? s_except_rental_yn : "N");
            $M.setValue("s_except_agency_yn", (s_except_agency_yn == "Y") ? s_except_rental_yn : "N");
            $M.setValue("s_campaign_yn", (s_campaign_yn == "Y") ? s_campaign_yn : "N");

        }


        function fnChangeOptimeYn(obj) {
            // 체크여부 확인
            if ($(obj).is(":checked") == true) {
                $(obj).val("Y");
                $("#s_optime_period").attr("disabled", false); 		//활성화
                $("#s_start_optime").prop("readonly", false); 		//활성화
                $("#s_end_optime").prop("readonly", false); 		//활성화
            } else {
                $(obj).val("N");
                $("#s_optime_period").attr("disabled", true); 		//비활성화
                $("#s_start_optime").prop("readonly", true); 		//비활성화
                $("#s_end_optime").prop("readonly", true); 			//비활성화
            }
        }

        // 기준정보 재생성
        function goChangeSave() {
            var msg = "기준정보를 재생성 하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page + "/updateStandardInfo", '', {method: 'POST'},
                function (result) {
                    if (result.success) {
                    	location.reload();
                    }
                }
            );
        }

        // 문자발송
        function fnSendSms() {

            var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
            if (items.length == 0) {
                alert("체크된 데이터가 없습니다.");
                return false
            }

            var params = {
                sms_send_type_cd: "2",
                req_sendtarger_yn: "Y"
            };
            openSendSmsPanel($M.toGetParam(params));
        }


        function reqSendTargetList() {

            var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

            var parentTargetList = [];

            for (var i = 0; i < items.length; i++) {
                var obj = new Object();
                obj['phone_no'] = items[i].real_hp_no;
                obj['receiver_name'] = items[i].real_cust_name;
                obj['ref_key'] = items[i].cust_no;
                parentTargetList.push(obj);
            }

            return parentTargetList;
        }

        function fnDownloadExcel() {
            // 엑셀 내보내기 속성
            var exportProps = {
                exceptColumnFields: []
            };
            fnExportExcel(auiGrid, "담당별장비관리", exportProps);
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="70px">
                                <col width="100px">
                                <col width="50px">
                                <col width="110px">
                                <col width="50px">
                                <col width="210px">
                                <col width="660px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>판매기간</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}">
                                            </div>
                                        </div>

                                        <!-- <details data-popover="up">

                                    </details> -->
                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                            <jsp:param name="st_field_name" value="s_start_dt"/>
                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
                                            <jsp:param name="click_exec_yn" value="Y"/>
                                            <jsp:param name="exec_func_name" value="goSearch();"/>
                                        </jsp:include>
                                    </div>
                                </td>
                                <td colspan="4">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="optime_yn" name="optime_yn" value="Y" onclick="javascript:fnChangeOptimeYn(this);">
                                        <div class="col-form-label" style="width:80px;">평균가동시간</div>
                                        <select id="s_optime_period" name="s_optime_period" class="form-control width60px">
                                            <option value="01" selected="selected">1개월</option>
                                            <option value="03">3개월</option>
                                            <option value="06">6개월</option>
                                            <option value="12">12개월</option>
                                        </select>
                                        <div class="col-3">
                                            <input type="text" class="form-control  width80px" name="s_start_optime" id="s_start_optime" placeholder="시간(h)이상" datatype="int">
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-3">
                                            <input type="text" class="form-control  width80px" name="s_end_optime" id="s_end_optime" placeholder="시간(h)이하" datatype="int">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>메이커</th>
                                <td>
<!--                                     <select id="s_maker_cd" name="s_maker_cd" class="form-control"> -->
<!--                                         <option value="">- 전체 -</option> -->
<%--                                         <c:forEach items="${codeMap['MAKER']}" var="item"> --%>
<%--                                             <c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}"> --%>
<%--                                                 <option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option> --%>
<%--                                             </c:if> --%>
<%--                                         </c:forEach> --%>
<!--                                     </select> -->

<!-- 									21.08.03 (SR:12007) 메이커 다중조회 추가 - 황빛찬 -->
									<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd_str" name="s_maker_cd_str" easyui="combogrid"
										   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
                                </td>
                                <th>모델</th>
                                <td>
                                    <jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
                                        <jsp:param name="required_field" value="s_machine_name"/>
                                        <jsp:param name="s_maker_cd" value=""/>
                                        <jsp:param name="s_machine_type_cd" value=""/>
                                        <jsp:param name="s_sale_yn" value=""/>
                                        <jsp:param name="readonly_field" value=""/>
                                    </jsp:include>
                                </td>
                                <th>부서</th>
                                <td class="pr10">
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <select class="form-control" name="s_center_org_code" id="s_center_org_code" onchange="javascript:goSearchCenterOrgMem(this);">
                                                <option value="">- 전체 -</option>
                                                <c:forEach var="item" items="${orgCenterList}">
                                                    <option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if> >${item.org_name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-7">
                                            <select class="form-control" id="s_center_mem_no" name="s_center_mem_no" alt="담당직원">
                                                <option value="">- 전체 -</option>
                                                <c:forEach var="item" items="${memList}">
                                                    <option value="${item.mem_no}">${item.mem_name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_include_stop_yn" name="s_include_stop_yn" value="Y" checked="checked" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_include_stop_yn">거래정지품목포함</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_cap_yn" name="s_cap_yn" value="Y" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_cap_yn">CAP</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_yk_yn" name="s_except_yk_yn" value="Y" checked="checked" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_except_yk_yn">YK건기제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_used_yn" name="s_except_used_yn" value="Y" checked="checked" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_except_used_yn">중고장비제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_rental_yn" name="s_except_rental_yn" value="Y" checked="checked" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_except_rental_yn">임대장비제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_campaign_yn" name="s_campaign_yn" value="Y" onclick="javascript:fnChangeGubun();">
                                        <label class="form-check-label" for="s_campaign_yn">캠페인대상</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_agency_yn" name="s_except_agency_yn" value="Y" onclick="javascript:fnChangeGubun();">
                                        <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                        <%--<label class="form-check-label" for="s_except_agency_yn">대리점제외</label>--%>
                                        <label class="form-check-label" for="s_except_agency_yn">위탁판매점제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_extend_target_yn" name="s_extend_target_yn" value="Y">
                                        <label class="form-check-label mr5" for="s_extend_target_yn">연장동의대상자</label>
                                    </div>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="left" style="margin-left:50px;">
                                <span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}&nbsp;&nbsp;&nbsp;</span>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
                            </div>
                            <div class="right">
                                <div class="form-check form-check-inline">
                                    <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                        <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                    </c:if>
                                    <label for="s_toggle_column" style="color:black;">
                                        <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
                                    </label>
                                </div>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
                            <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                    </div>
                    <!-- /그리드 서머리, 컨트롤 영역 -->
                </div>

            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
