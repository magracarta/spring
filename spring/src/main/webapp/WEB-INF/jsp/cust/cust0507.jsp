<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 1:1문의
-- 작성자 : 한승우
-- 최초 작성일 : 2023-07-27 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<!-- script -->
<script type="text/javascript">

    var page = 1;
    var moreFlag = "N";
    var isLoading = false;

    var machinePlantSeqArr = [];

    var resultData; // 검색결과 임시저장

    $(document).ready(function() {
        createAUIGrid();
        $M.setValue("s_start_dt", "${searchDtMap.s_start_dt}");
        $M.setValue("s_end_dt", "${searchDtMap.s_end_dt}");
        goSearch();
    })

    function fnDownloadExcel() {
        var exportProps = {
            // 제외항목
        };
        fnExportExcel(auiGrid, "1:1문의", exportProps);
    }

    // 조회
    function goSearch() {
        if($M.getValue("s_cust_name") == "" && $M.getValue("s_body_no") == "" && $M.getValue("s_machine_name") == ""
            && ($M.getValue("s_start_dt") == "" && $M.getValue("s_end_dt") == "")) {
            alert("검색조건 중 하나는 필수입니다.");
            return false;
        }
        // 조회 버튼 눌렀을경우 1페이지로 초기화
        page = 1;
        moreFlag = "N";
        fnSearch(function(result){
            resultData = result; // 검색결과 임시 저장
            AUIGrid.setGridData(auiGrid, result.list);
            $("#total_cnt").html(result.total_cnt);
            $("#curr_cnt").html(result.list.length);
            if (result.more_yn == 'Y') {
                moreFlag = "Y";
                page++;
            };
        });
    }

    function fnSearch(successFunc) {
        isLoading = true;
        var param = {
            "s_start_dt" : $M.getValue("s_start_dt"),
            "s_end_dt" : $M.getValue("s_end_dt"),
            "s_cust_name" : $M.getValue("s_cust_name"),
            "s_body_no" : $M.getValue("s_body_no"),
            "s_machine_plant_seq_str" : $M.getArrStr(machinePlantSeqArr, {isEmpty : true}),
            "s_c_cs_type_cd": $M.getValue("s_c_cs_type_cd"),
            "s_comp_yn": $M.getValue("s_comp_yn"),
            "s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
            "s_sort_key" : "a.reg_date desc, a.comp_yn",
            "s_sort_method" : "asc",
            "page" : page,
            "rows" : $M.getValue("s_rows"),
        };

        $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
            function(result){
                isLoading = false;
                if(result.success) {
                    successFunc(result);
                };
            }
        );
    }

    // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
    function fnScollChangeHandelr(event) {
        if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
            goMoreData();
        };
    }

    function goMoreData() {
        fnSearch(function(result){
            result.more_yn == "N" ? moreFlag = "N" : page++;
            if (result.list.length > 0) {
                console.log(result.list);
                AUIGrid.appendData("#auiGrid", result.list);
                $("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
            };
        });
    }

    function enter(fieldObj) {
        var field = ["s_cust_name", "s_body_no"];
        $.each(field, function() {
            if(fieldObj.name == this) {
                goSearch(document.main_form);
            };
        });
    }

    //그리드생성
    function createAUIGrid() {
        var gridPros = {
            rowIdField: "c_cs_seq",
            usePaging: false,
            height: 565,
            enableFilter :true
        };
        // AUIGrid 칼럼 설정
        var columnLayout = [
            {
                dataField: "c_cs_seq",
                visible: false
            },
            {
                headerText: "등록일시",
                dataField: "reg_date",
                width: "150",
                minWidth: "75",
                editable : false,
                filter : {
                    showIcon : true
                }
            },
            {
                headerText: "고객명",
                dataField: "cust_name",
                width: "130",
                minWidth: "120",
                style: "aui-center aui-popup",
                editable : false,
                filter : {
                    showIcon : true
                }
            },
            {
              dataField: "cust_no",
              visible: false
            },
            {
                headerText: "고객등급",
                dataField: "cust_grade_str",
                width: "140",
                minWidth: "120",
                style: "aui-center"
            },
            {
                headerText: "연락처",
                dataField: "hp_no",
                width: "115",
                minWidth: "110",
                style: "aui-center"
            },
            {
                headerText: "메이커",
                dataField: "maker",
                width: "115",
                minWidth: "110",
                style: "aui-center"
            },
            {
                headerText: "모델명",
                dataField: "machine_name",
                width: "115",
                minWidth: "110",
                style: "aui-center",
            },
            {
                headerText: "차대번호",
                dataField: "body_no",
                width: "150",
                minWidth: "145",
                style: "aui-center aui-popup",
            },
            {
                dataField: "machine_seq",
                visible: false
            },
            {
                headerText: "문의구분",
                dataField: "c_cs_type_name",
                width: "130",
                minWidth: "120",
                style: "aui-center",
                filter: {
                    showIcon: true
                }
            },
            {
                headerText: "문의내용",
                dataField: "ask_text",
                width: "260",
                minWidth: "120",
                style: "aui-center aui-popup",
            },
            {
                headerText: "문의첨부파일",
                dataField: "ask_file_cnt",
                width: "100",
                minWidth: "60",
                style: "aui-center",
            },
            {
                headerText: "답변내용",
                dataField: "reply_text",
                width: "260",
                minWidth: "120",
                style: "aui-center",
            },
            {
                headerText: "답변첨부파일",
                dataField: "reply_file_cnt",
                width: "100",
                minWidth: "60",
                style: "aui-center",
            },
            {
                headerText: "처리상태",
                dataField: "comp_yn_text",
                width: "110",
                minWidth: "105",
                style: "aui-center",
                filter: {
                    showIcon: true
                },
                // labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                //     return item["comp_yn"] == "Y" ? "답변완료" : "답변대기";
                // }
            },
            {
                headerText: "처리일시",
                dataField: "comp_date",
                width: "150",
                minWidth: "75",
                style: "aui-center",
            },
            {
                headerText: "처리자",
                dataField: "comp_mem_name",
                width: "75",
                minWidth: "75",
                style: "aui-center",
            },
            {
                dataField : "aui_status_cd",
                visible : false
            }
        ];
        auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
        AUIGrid.setGridData(auiGrid, []);
        $("#auiGrid").resize();

        AUIGrid.bind(auiGrid, "cellClick", function (event) {
            // 고객정보 상세 팝업
            if (event.dataField == "cust_name") {
                var custNo = event.item["cust_no"];
                var param = {
                    cust_no : custNo
                }
                $M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : ""});
            } else if(event.dataField == "body_no") {
                var popupOption = "";
                var params = {
                    s_machine_seq : event.item.machine_seq,
                };
                // 장비대장상세 팝업 호출
                $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
            } else if(event.dataField == 'ask_text'){
                var param = {
                    c_cs_seq : event.item["c_cs_seq"]
                };

                var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=750, left=0, top=0";
                $M.goNextPage('/cust/cust0507p01', $M.toGetParam(param), {popupStatus : poppupOption});
            };
        });
        AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
    }

    // 모델명 조회조건 초기화
    function setModelInfoEmpty(){
        machinePlantSeqArr = [];
        $M.setValue("s_machine_name", "");
    }

    // (2021-07-15 (SR:11316) 모델 다중 조회 추가 - 황빛찬)
    function setModelInfo(data) {
        var machineName = data[0].machine_name;
        var machineCnt = data.length - 1;

        if (data.length > 1) {
            machineName += " 외" + machineCnt + "건";
        }

        $M.setValue("s_machine_name", machineName);

        machinePlantSeqArr = [];
        for (var i = 0; i < data.length; i++) {
            machinePlantSeqArr.push(data[i].machine_plant_seq);
        }
    }
</script>
<!-- /script -->
<body>
<form name="main_form" id="main_form">
<%--    <input type="hidden" id="s_machine_plant_seq" name="s_machine_plant_seq">--%>
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
                <div class="search-wrap pr" style="padding:10px;">
                    <table class="table">
                        <colgroup>
                            <!-- 등록일 -->
                            <col width="60px">
                            <col width="260px">
                            <!-- 고객명 -->
                            <col width="60px">
                            <col width="110px">
                            <!-- 차대번호 -->
                            <col width="80px">
                            <col width="140px">
                            <!-- 모델 -->
                            <col width="60px">
                            <col width="110px">
                            <!-- 문의구분 -->
                            <col width="70px">
                            <col width="110px">
                            <!-- 처리상태 -->
                            <col width="70px">
                            <col width="110px">
                            <!-- 조회 -->
                            <col width="*">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>등록일</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" alt="시작일" dateFormat="yyyy-MM-dd" value="">
                                        </div>
                                    </div>
                                    <div class="col-auto">~</div>
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" alt="종료일" dateFormat="yyyy-MM-dd" value="">
                                        </div>
                                    </div>
                                    <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                        <jsp:param name="st_field_name" value="s_start_dt"/>
                                        <jsp:param name="ed_field_name" value="s_end_dt"/>
                                        <jsp:param name="click_exec_yn" value="Y"/>
                                        <jsp:param name="exec_func_name" value="goSearch();"/>
                                    </jsp:include>
                                </div>
                            </td>
                            <th>고객명</th>
                            <td>
                                <div class="icon-btn-cancel-wrap">
                                    <input type="text" class="form-control" id="s_cust_name" name="s_cust_name" alt="고객명">

                                </div>
                            </td>
                            <th>차대번호</th>
                            <td>
                                <div class="icon-btn-cancel-wrap">
                                    <input type="text" class="form-control" placeholder="-없이 숫자만" id="s_body_no" name="s_body_no"  alt="차대번호">

                                </div>
                            </td>
                            <th>모델</th>
                            <td>
                                <div class="form-row inline-pd pl5">
                                    <div class="input-group">
                                        <input type="text" id="s_machine_name" name="s_machine_name" class="form-control border-right-0" readonly onclick="setModelInfoEmpty()">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('setModelInfo', 'Y');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </div>
                            </td>
                            <th>문의구분</th>
                            <td>
                                <select class="form-control" style="width:100px;" id="s_c_cs_type_cd" name="s_c_cs_type_cd" >
                                    <option value="">- 전체 -</option>
                                    <c:forEach var="item" items="${csTypeList}">
                                        <c:if test="${item.code_value ne '---'}">
                                            <option value="${item.code_value}">${item.code_name}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td>
                            <th>처리상태</th>
                            <td>
                                <select class="form-control" style="width:100px;" id="s_comp_yn" name="s_comp_yn" >
                                    <option value="">- 전체 -</option>
                                    <option value="N">답변대기</option>
                                    <option value="Y">답변완료</option>
                                </select>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /검색영역 -->
                <!-- 그리드 타이틀, 컨트롤 영역 -->
                <div class="row">
                    <div id="palce_area_filter" class="col-2" style="display: none">
                        <div id="auiGridArea" style="margin-top: 1px; height: 630px;"></div>
                    </div>
                    <div id="result_area" class="col-12"> <!-- 결과물 영역 -->
                        <div class="title-wrap mt10">
                            <h4>조회결과</h4>
                            <div class="btn-group">
                                <div class="right">
                                    <div class="form-check form-check-inline">
                                        <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                            <input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                            <label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
                                        </c:if>
                                    </div>
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                                </div>
                            </div>
                        </div>
                        <div id="auiGrid" style="margin-top: 5px;"></div>
                        <!-- 그리드 서머리, 컨트롤 영역 -->
                        <div class="btn-group mt5">
                            <div class="left">
                                <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                            </div>
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                            </div>
                        </div>
                        <!-- /그리드 서머리, 컨트롤 영역 -->
                    </div>
                </div>
                <!-- /그리드 타이틀, 컨트롤 영역 -->
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
</form>
</body>
</html>
