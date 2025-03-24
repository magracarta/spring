<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 정비이력 키워드검색 > null > null
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
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

        var machineCnt = 0;
        var breakCnt = 0;
        var partCnt = 0;

        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
        });

		function enter(fieldObj) {
			var field = ["s_repair_text", "s_ref_text"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                autoGridHeight: false,
                applyRestPercentWidth: false,
            };

            var columnLayoutList = [
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    style: "aui-center",
                    width: "7%"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center aui-popup",
                    width: "6%"
                },
                {
                    headerText: "처리일",
                    dataField: "as_dt",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    width: "7%"
                },
                {
                    headerText: "차주명",
                    dataField: "cust_name",
                    width: "20%",
                    style: "aui-center",
                    width: "5%"
                },
                {
                    headerText: "연락처",
                    dataField: "hp_no",
                    style: "aui-center",
                    width: "10%"

                },
                {
                    headerText: "수리내역",
                    dataField: "repair_text",
                    style: "aui-left",
                    width: "55%",
                    renderer: {
                        type: "TemplateRenderer",
                        labelFunction: function (rowIndex, columnIndex, value, headerText, item) { // HTML 템플릿 작성
                            value = value.replace(/\r|\n|\r\n/g, "<br/>");

                            return value;
                        }
                    },
                },
                {
                    headerText: "처리자",
                    dataField: "reg_mem_name",
                    style: "aui-center",
                    width: "10%"
                },
                {
                    headerText: "AS번호",
                    dataField: "as_no",
                    visible: false
                },
                {
                    headerText: "정비일지타입",
                    dataField: "as_repair_type_ro",
                    visible: false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayoutList, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "body_no") {
                    var params = {
                        s_as_no: event.item.as_no
                    };
                    var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
                    if (event.item.as_repair_type_ro == "R") {
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                    } else {
                        $M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                }
            });

            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
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
            if ($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") != "") {
                if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                    return;
                }
            }

            var machinePlantArr = $("input[id^='machine_plant_seq']");
            var breakPartArr = $("input[id^='break_part_seq']");
            var partArr = $("input[id^='part_no']");
            var s_machine_plant = "";
            var s_break_part = "";
            var s_part = "";

            for (var i = 0; i < machinePlantArr.length; i++) {
                s_machine_plant += machinePlantArr[i].value + "#";
            }

            for (var i = 0; i < breakPartArr.length; i++) {
                s_break_part += breakPartArr[i].value + "#";
            }

            for (var i = 0; i < partArr.length; i++) {
                s_part += partArr[i].value + "#";
            }

            var param = {
                "s_machine_plant_seq": s_machine_plant,
                "s_break_part_seq": s_break_part,
                "s_part_no": s_part,
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_repair_text": $M.getValue("s_repair_text"),
                "s_ref_text": $M.getValue("s_ref_text"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "page": page,
                "rows": $M.getValue("s_rows")
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);

                        // 만약 칼럼 사이즈들의 총합이 그리드 크기보다 작다면, 나머지 값들을 나눠 가져 그리드 크기에 맞추기
                        var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
                        // 구해진 칼럼 사이즈를 적용 시킴.
                        AUIGrid.setColumnSizeList(auiGrid, colSizeList);
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

        function fnDownloadExcel() {
            // 엑셀 내보내기 속성
            var exportProps = {
                //제외항목
            };
            fnExportExcel(auiGrid, "정비이력 키워드검색", exportProps);
        }

        function fnDuplicateCheck(item, type) {
            var checkList;
            switch (type) {
                case "machine" :
                    checkList = $("input[id^='machine_plant_seq']");
                    break;
                case "break" :
                    checkList = $("input[id^='break_part_seq']");
                    break;
                case "part" :
                    checkList = $("input[id^='part_no']");
                    break;
                default :
                    break;
            }

            for (var i = 0; i < checkList.length; i++) {
                if (checkList[i].value == item) {
                    return false;
                }
            }

            return true;
        }

        function fnDeleteItem(itemId) {
            $("#" + itemId).remove();
        }

        function goBreakPart() {

            var params = [{}];
            var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=420, left=0, top=0";
            $M.goNextPage('/serv/serv0405p01', $M.toGetParam(params), {popupStatus: popupOption});
        }

        function fnSetPartInfo(itemArr) {
            console.log(itemArr);
            var str = "";
            for (var i = 0; i < itemArr.length; i++) {
                if (fnDuplicateCheck(itemArr[i].part_no, "part")) {
                    str += "<li class='icon-btn-cancel-wrap' id='part" + partCnt + "'>";
                    str += "		<div class='select-area'>";
                    str += "		<input type='hidden' id='part_no" + partCnt + "' name='part_no" + partCnt + "' value='" + itemArr[i].part_no + "'>"
                    str += "		<label>" + itemArr[i].part_name + "</label>";
                    str += "		</div>";
                    str += "	<button type='button' onclick='javascript:fnDeleteItem(\"part" + partCnt + "\");' class='icon-btn-cancel'><i class='material-iconsclose font-16 text-default-50'></i></button>";
                    str += "</li>";
                    partCnt++;
                }
            }
            $("#partList").append(str);
        }

        function fnSetModelResult(itemArr) {

            var str = "";
            for (var i = 0; i < itemArr.length; i++) {
                if (fnDuplicateCheck(itemArr[i].machine_plant_seq, "machine")) {
                    str += "<li class='icon-btn-cancel-wrap' id='machine" + machineCnt + "'>";
                    str += "	<div class='select-area'>";
                    str += "		<input type='hidden' id='machine_plant_seq" + machineCnt + "' name='machine_plant_seq" + machineCnt + "' value='" + itemArr[i].machine_plant_seq + "'>"
                    str += "		<label>" + itemArr[i].machine_name + "</label>";
                    str += "	</div>";
                    str += "	<button type='button' onclick='javascript:fnDeleteItem(\"machine" + machineCnt + "\");' class='icon-btn-cancel'><i class='material-iconsclose font-16 text-default-50'></i></button>";
                    str += "</li>";
                    machineCnt++;
                }
            }
            $("#machineList").append(str);
        }

        function fnSetBreakInfo(item) {
            var str = "";
            if (fnDuplicateCheck(item.break_part_seq, "break")) {
                str += "<li class='icon-btn-cancel-wrap' id='breakPart" + breakCnt + "'>";
                str += "		<div class='select-area'>";
                str += "		<input type='hidden' id='break_part_seq" + breakCnt + "' name='break_part_seq" + breakCnt + "' value='" + item.break_part_seq + "'>"
                str += "		<label>" + item.break_part_name + "</label>";
                str += "		</div>";
                str += "	<button type='button' onclick='javascript:fnDeleteItem(\"breakPart" + breakCnt + "\");' class='icon-btn-cancel'><i class='material-iconsclose font-16 text-default-50'></i></button>";
                str += "</li>";
                breakCnt++;
            }

            $("#breakList").append(str);
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
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="60px">
                                <col width="">
                                <col width="50px">
                                <col width="">
                                <col width="50px">
                                <col width="">
                                <col width="50px">
                                <col width="300px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="v-align-top" rowspan="3">장비코드</th>
                                <td class="v-align-top" rowspan="3">
                                    <div class="form-row inline-pd widthfix" style="align-items: flex-start;">
                                        <div class="col" style="width: calc(100% - 32px)">
                                            <ul class="multiselect-s-wrap" style="height: 80px;" id="machineList" name="machineList">
                                            </ul>
                                        </div>
                                        <div class="col width22px">
                                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('fnSetModelResult', 'Y');"><i class="material-iconssearch"></i></button>
                                        </div>
                                    </div>
                                </td>
                                <th class="v-align-top" rowspan="3">고장부위</th>
                                <td class="v-align-top" rowspan="3">
                                    <div class="form-row inline-pd widthfix" style="align-items: flex-start;">
                                        <div class="col" style="width: calc(100% - 32px)">
                                            <ul class="multiselect-s-wrap" style="height: 80px;" id="breakList">
                                            </ul>
                                        </div>
                                        <div class="col width22px">
                                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBreakPart();"><i class="material-iconssearch"></i></button>
                                        </div>
                                    </div>
                                </td>
                                <th class="v-align-top" rowspan="3">사용부품</th>
                                <td class="v-align-top" rowspan="3">
                                    <div class="form-row inline-pd widthfix" style="align-items: flex-start;">
                                        <div class="col" style="width: calc(100% - 32px)">
                                            <ul class="multiselect-s-wrap" style="height: 80px;" id="partList">

                                            </ul>
                                        </div>
                                        <div class="col width22px">
                                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchPartPanel('fnSetPartInfo', 'Y');"><i class="material-iconssearch"></i></button>
                                        </div>
                                    </div>
                                </td>
                                <th>처리기간</th>
                                <td colspan="2">
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width110px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_start_dt}" alt="조회 시작일">
                                            </div>
                                        </div>
                                        <div class="col width16px text-center">~</div>
                                        <div class="col width120px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="조회 완료일">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>수리내용</th>
                                <td colspan="2">
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width140px">
                                            <input type="text" id="s_repair_text" name="s_repair_text" class="form-control">
                                        </div>
                                        <div class="col width140px">
                                            <div class="form-check form-check-inline">
                                                <input class="form-check-input" id="s_show_text" name="s_show_text" type="checkbox">
                                                <label class="form-check-label" for="s_show_text">수리내용 모두표시</label>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>참고사항</th>
                                <td>
                                    <input type="text" id="s_ref_text" name="s_ref_text" class="form-control">
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
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
                    <!-- /조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
                            <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>