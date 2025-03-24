<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > CAP Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-21 19:54:29
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
        var asCallResultJson = JSON.parse('${codeMapJsonObj['AS_CALL_RESULT']}');
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            fnInit();
        });

        function fnInit() {
            var orgType = "${inputParam.org_type}";
            if (orgType != "BASE") {
                $("#s_center_org_code").prop("disabled", true);
            }

            var now = $M.getCurrentDate("yyyyMMdd");
            if ("${inputParam.s_work_gubun}" != "Y") {
                $M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
                $M.setValue("s_end_dt", $M.toDate(now));
            }

            if ("${inputParam.s_work_gubun}" == "Y") {
                $M.setValue("s_treat_yn", "");
                $("#s_center_org_code").prop("disabled", true);

            }
            
            if("${inputParam.s_body_no}" != "") {
            	$M.setValue("s_body_no", "${inputParam.s_body_no}");
            	$M.setValue("s_end_dt", "${inputParam.s_plan_dt}");
                $M.setValue("s_treat_yn", "");
            }
            goSearch();
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                showStateColumn: true,
                editable: true,
                enableFilter: true,
                headerHeight : 40
            };

            var columnLayout = [
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    style: "aui-center aui-popup",
                    editable: false,
					width : "110", 
					minWidth : "110",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    style: "aui-left",
                    editable: false,
					width : "105", 
					minWidth : "105",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center aui-popup",
                    editable: false,
					width : "150", 
					minWidth : "150",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "연락처",
                    dataField: "hp_no",
                    style: "aui-center",
                    editable: false,
					width : "110", 
					minWidth : "110",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "출하일자",
                    dataField: "out_dt",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    editable: false,
					width : "75", 
					minWidth : "75",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "현재 차수",
                    dataField: "cap_cnt",
                    style: "aui-center",
                    editable: false,
					width : "75", 
					minWidth : "75",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "예정일자",
                    dataField: "plan_dt",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    editable: false,
					width : "75", 
					minWidth : "75",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "담당센터",
                    dataField: "center_org_name",
                    style: "aui-center",
                    editable: false,
					width : "70", 
					minWidth : "70",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "AS담당",
                    dataField: "service_mem_name",
                    style: "aui-center",
                    editable: false,
					width : "70", 
					minWidth : "70",
                    filter: {
                        showIcon: true
                    },
                },
                {
                    headerText: "Call 일자",
                    dataField: "reg_dt",
                    style: "aui-center aui-popup",
					width : "85", 
					minWidth : "85",
                    editable: false,
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    filter: {
                        showIcon: true,
						displayFormatValues : true,
                    },
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        return "aui-grid-selection-row-satuday-bg";
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (item.change_plan_dt == "" && value == "") {
                            return "등록";
                        } else if (item.change_plan_dt != "") {
                            return $M.dateFormat(value, "yy-MM-dd");
                        }
                    }
                },
                /* {
                    headerText: "예약일자<br\>변경",
                    dataField: "change_plan_dt",
                    style: "aui-center aui-editable",
                    dataInputString: "yyyymmdd",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    editRenderer: {
                        type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
                        defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
                        onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
                        maxlength: 8,
                        onlyNumeric: true, // 숫자만
                        validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
                            return fnCheckDate(oldValue, newValue, rowItem);
                        },
                        showEditorBtnOver: true
                    },
                    editable: true,
					width : "65", 
					minWidth : "65"
                },
                {
                    headerText: "통화<br\>구분",
                    dataField: "as_call_result_cd",
                    style: "aui-center aui-editable",
                    showEditorBtn: false,
                    showEditorBtnOver: false,
                    editable: true,
                    editRenderer: {
                        type: "DropDownListRenderer",
                        list: asCallResultJson,
                        keyField: "code_value",
                        valueField: "code_name"
                    },
                    labelFunction: function (rowIndex, columnIndex, value) {
                        for (var i = 0; i < asCallResultJson.length; i++) {
                            if (value == asCallResultJson[i].code_value) {
                                return asCallResultJson[i].code_name;
                            }
                        }
                        return value;
                    },
					width : "60", 
					minWidth : "60"
                },
                {
                    headerText: "내용",
                    dataField: "remark",
					width : "190", 
					minWidth : "190",
                    style: "aui-left aui-editable"
                },
                {
                    headerText: "처리자",
                    dataField: "reg_mem_name",
                    style: "aui-center",
                    editable: false,
					width : "60", 
					minWidth : "60"
                }, */
                {
                    headerText: "고객번호",
                    dataField: "cust_no",
                    visible: false
                },
                {
                    headerText: "장비대장번호",
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "통화순번",
                    dataField: "seq_no",
                    visible: false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "cust_name") {
                    var param = {
                        "cust_no": event.item.cust_no
                    };

                    var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
                    $M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus: poppupOption});
                }

                if (event.dataField == "body_no") {
                    var params = {
                        "s_machine_seq": event.item.machine_seq
                    };

                    var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
                    $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
                }

                if (event.dataField == "reg_dt") {
                    var params = {
						"s_machine_seq" : event.item.machine_seq,
						"s_cap_cnt" : event.item.cap_cnt
                    };

                    var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
                    if(event.item.change_plan_dt == "") {
	                    $M.goNextPage('/serv/serv040407p01', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						$M.goNextPage('/serv/serv040407p02', $M.toGetParam(params), {popupStatus: popupOption});
					}
				}
            });

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "CAPCall");
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
            var param = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_center_org_code": $M.getValue("s_center_org_code"),
                "s_treat_yn": $M.getValue("s_treat_yn"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_total_search": $M.getValue("s_total_search"),
                "s_service_mem_no": $M.getValue("s_service_mem_no"),
                "s_body_no": $M.getValue("s_body_no"),
                "s_cust_name": $M.getValue("s_cust_name"),
                "page": page,
                "rows": $M.getValue("s_rows")
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
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
        
		function enter(fieldObj) {
			var field = ["s_body_no", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
    </script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="s_total_search" name="s_total_search">
<input type="hidden" id="s_service_mem_no" name="s_service_mem_no" value="${inputParam.s_service_mem_no}">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="250px">
                                <col width="70px">
                                <col width="100px">
                                <col width="70px">
                                <col width="100px">
                                <col width="70px">
                                <col width="160px">
                                <col width="70px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>예정일자</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width110px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일" value="${inputParam.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col width16px text-center">~</div>
                                        <div class="col width120px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="조회 완료일" value="${inputParam.s_end_dt}">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <th>담당센터</th>
                                <td>
                                    <select class="form-control" id="s_center_org_code" name="s_center_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${orgCenterList}" var="item">
                                            <option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.org_code}">selected="selected"</c:if> >${item.org_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>고객명</th>
                                <td>
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
                                </td>
                                <th>차대번호</th>
                                <td>
									<input type="text" class="form-control" id="s_body_no" name="s_body_no">
                                </td>
                                <th>일지상태</th>
                                <td>
                                    <select id="s_treat_yn" name="s_treat_yn" class="form-control">
                                        <option value="">- 전체 -</option>
                                        <option value="N" selected="selected">미결</option>
                                    </select>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- CAP Call 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>CAP Call 조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                    </div>
                                </c:if>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /CAP Call 조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>