<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > 급여/손익 > 더존 급여 코드 관리 팝업
-- 작성자 : 정재호
-- 최초 작성일 : 2022-12-09 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
      var auiGrid;
      var orgCodeList;
      var showPosPdList = [{"code_name": "지급항목", "code_value": "P"}, {"code_name": "공제항목", "code_value": "D"}];

      $(document).ready(function () {
        createAUIGrid();
        goSearch();
      });

      function createAUIGrid() {
        var gridPros = {
          rowIdField: "_$uid",
          enableFilter: true,
          enableSorting: false,
          editable: true,
          rowStyleFunction: function (rowIndex, item) {
            if (item.aui_status_cd !== "") {
              if (item.aui_status_cd == "D") { // 기본
                return "aui-status-default";
              } else if (item.aui_status_cd == "C") { // 진행예정
                return "aui-status-complete";
              }
            }
          }
        };

        var columnLayout = [
          {
            headerText: "코드명",
            dataField: "code_name",
            editable: true,
            width: "200",
            minWidth: "190",
            headerTooltip: {
              show: true,
              tooltipHtml: "필수 사용 코드는 수정 불가 처리되며 순서는 이동 가능합니다."
            },
            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
              if (item.code_v3 == "N") {
                return "aui-center";
              } else {
                return "aui-editable";
              }
            },
          },
          {
            headerText: "사용여부",
            dataField: "use_yn",
            editable: true,
            width: "100",
            minWidth: "90",
            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
              if (item.code_v3 == "N") {
                return "aui-center";
              } else {
                return "aui-editable";
              }
            },
            headerTooltip: {
              show: true,
              tooltipHtml: "- 월급여업로드 팝업의 사용 여부를 정합니다.<br/>- 미사용시 급여/손익, 명세서에서도 사라집니다.<br/> (Y: 사용, N: 미사용)"
            },
            renderer: {
              type: "CheckBoxEditRenderer",
              // showLabel: true, // 참, 거짓 텍스트 출력여부( 기본값 false )
              editable: true, // 체크박스 편집 활성화 여부(기본값 : false)
              checkValue: 'Y', // true, false 인 경우가 기본
              unCheckValue: 'N',

              // 체크박스 disabled 함수
              disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
                if (item.code_v3 == "N")
                  return true; // true 반환하면 disabled 시킴
                return false;
              }
            }
          },
          {
            headerText: "명세서, 급여/손익",
            children: [
              {
                headerText: "표시여부",
                dataField: "code_v2",
                width: "100",
                minWidth: "90",
                styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                  if (item.use_change_yn == "N") {
                    return "aui-center";
                  } else {
                    return "aui-editable";
                  }
                },
                headerTooltip: {
                  show: true,
                  tooltipHtml: "- 급여/손익, 명세서출력 페이지에서 표시 여부를 정합니다.<br/> (Y: 표시, N: 미표시)"
                },
                renderer: {
                  type: "CheckBoxEditRenderer",
                  // showLabel: true, // 참, 거짓 텍스트 출력여부( 기본값 false )
                  editable: true, // 체크박스 편집 활성화 여부(기본값 : false)
                  checkValue: 'Y', // true, false 인 경우가 기본
                  unCheckValue: 'N',

                  // 체크박스 disabled 함수
                  disabledFunction: function (rowIndex, columnIndex, value, isChecked, item, dataField) {
                    if (item.code_v3 == "N")
                      return true; // true 반환하면 disabled 시킴
                    return false;
                  }
                }
              },
              {
                headerText: "노출위치",
                dataField: "code_v1",
                width: "100",
                minWidth: "90",
                headerTooltip: {
                  show: true,
                  tooltipHtml: "- 지급내역과, 공제내역의 위치를 설정합니다."
                },
                styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                  if (item.code_v3 == "N") {
                    return "aui-center";
                  } else {
                    return "aui-editable";
                  }
                },
                editRenderer: {
                  type: "DropDownListRenderer",
                  showEditorBtn: false,
                  showEditorBtnOver: false,
                  list: showPosPdList, //key-value Object 로 구성된 리스트
                  keyField: "code_value", // key 에 해당되는 필드명
                  valueField: "code_name" // value 에 해당되는 필드명
                },
                labelFunction: function (rowIndex, columnIndex, value) {
                  for (var i = 0; i < showPosPdList.length; i++) {
                    if (value == showPosPdList[i].code_value) {
                      return showPosPdList[i].code_name;
                    }
                  }
                  return value;
                }
              },
            ]
          },
          {
            dataField: "sort_no",
            visible: false
          },
          {
            dataField: "aui_status_cd",
            visible: false
          },
          {
            dataField: "group_code",
            visible: false
          },
          {
            dataField: "code",
            visible: false
          },
          {
            dataField: "cmd",
            visible: false
          },
        ];

        auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
        AUIGrid.setGridData(auiGrid, []);

        AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
          if (event.item.code_v3 == 'N') {
            return false;
          }
          return true;
        });
      }

      // 선택 행들 위로 한 단계 올림
      function moveRowsToUp() {
        AUIGrid.moveRowsToUp(auiGrid);
      };

      // 선택 행들 아래로 한 단계 올림
      function moveRowsToDown() {
        AUIGrid.moveRowsToDown(auiGrid);
      };

      // 페이지 설명 호버 이벤트
      function show9() {
        document.getElementById("show9").style.display = "block";
      }

      // 페이지 설명 호버 이벤트
      function hide9() {
        document.getElementById("show9").style.display = "none";
      }

      // 검색
      function goSearch() {
        // var year_mon = $M.getCurrentDate("yyyy") + "01";
        var year_mon = $M.getValue("s_year") + "01";

        // 현재날짜와 검색 날짜가 같아야함
        // 매년 1월에만 저장 되므로 01월로 변경
        var is_now = ($M.getCurrentDate("yyyy") + "01") === ($M.getValue("s_year") + "01") ? 'Y' : 'N' ;

        var param = {
          "s_year_mon": year_mon,
          "is_now" : is_now
        };

        $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
          function (result) {
            if (result.success) {

              // 초기 셋팅
              orgCodeList = result.codeList;

              // 셋팅
              $("#total_cnt").html(orgCodeList.length);
              $("#maker_min").html(orgCodeList.length);
              $("#maker_max").html('${maker_max}');

              AUIGrid.setGridData(auiGrid, orgCodeList);
            }
          }
        );
      }

      // 닫기
      function fnClose() {
        window.close();
      }

      // 그리드 빈값 체크
      function fnCheckGridEmpty() {
        return AUIGrid.validateGridData(auiGrid, ["code_name"], "코드명은 필수로 입력해야 합니다.");
      }

      // 변경된 코드 리스트 가져오기
      function getChangeCodeList() {
        var gridData = AUIGrid.getGridData(auiGrid);

        // sort_no 조정
        gridData = gridData.map((ele, index) => {
          return {
            ...ele,
            sort_no: index + 1
          };
        });

        var changeCodeList = [];
        for (let i = 0; i < gridData.length; i++) {
          var grid = gridData[i];
          var orgin = orgCodeList[i];

          // 새로 추가된 케이스
          if (orgin == undefined) {
            changeCodeList.push(grid);
            continue;
          }

          // 순서가 바뀐 경우
          if (grid.code != orgin.code) {
            changeCodeList.push(grid);
          } else {
            // 사용여부, 표시여부, 노출위치
            if ((grid.use_yn != orgin.use_yn) ||
              (grid.code_v2 != orgin.code_v2) ||
              (grid.code_v1 != orgin.code_v1) ||
              (grid.code_name != orgin.code_name)
            ) {
              changeCodeList.push(grid);
            }
          }
        }

        return changeCodeList;
      }

      function goSave() {
        var currentDate = $M.getCurrentDate("yyyy") + "01";
        var searchDate = $M.getValue("s_year") + "01";
        if(currentDate !== searchDate) {
          alert("매년 1월에만 저장이 가능하며, 과거 데이터는 수정 할 수 없습니다.");
          return;
        }

        // 필수값 체크
        if (fnCheckGridEmpty(auiGrid) === false) {
          return false;
        }
        ;

        // 변경된 코드 리스트
        var changeCodeList = getChangeCodeList();
        if (changeCodeList.length == 0) {
          alert("변경된 정보가 없습니다.");
          return;
        }

        // 저장
        $M.goNextPageAjax(this_page + "/save", $M.jsonArrayToForm(changeCodeList), {method: "POST"},
          function (result) {
            if (result.success) {
              goSearch();
            }
          }
        );
      }

      function fnAdd() {
        var rowCount = AUIGrid.getRowCount(auiGrid);
        if (rowCount >= ${maker_max}) {
          alert("최대 추가 횟수를 넘을 수 없습니다.\n관리자에게 문의해주세요.");
          return;
        }

        // alert("행추가 개발중...");
        // 페이지 설명 호버 이벤트var item = new Object();
        if (fnCheckGridEmpty(auiGrid)) {
          var item = new Object();
          item.code_name = "";
          item.use_yn = "Y";
          item.code_v3 = 'Y';
          item.code_v2 = "Y";
          item.code_v1 = "P";
          item.aui_status_cd = "D";
          item.sort_no = (rowCount + 1) + "";
          item.group_code = "DZ_SALARY_ITEM";
          item.code = "COL_" + (rowCount + 1);
          item.cmd = 'C';
          AUIGrid.addRow(auiGrid, item, 'last');

          // 셋팅
          $("#total_cnt").html(AUIGrid.getRowCount(auiGrid));
          $("#maker_min").html(AUIGrid.getRowCount(auiGrid));
        }
      }

      function onChange() {
        console.log("sdfa");
        goSearch();
      }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <div class="popup-wrap width-100per">
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 검색조건 -->
            <div class="search-wrap mt5">
                <table class="table table-fixed">
                    <colgroup>
                        <col width="60px">
                        <col width="160px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>급여년월</th>
                        <td>
                            <div class="inline-pd">
                                <div class="col-auto">
                                    <select class="form-control essential-bg" onchange="onChange()" id="s_year" name="s_year"
                                            required="required" alt="급여년도">
                                        <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1"
                                                   varStatus="status">
                                            <c:set var="year_option" value="${status.end - i + status.begin}"/>
                                            <option value="${year_option}"
                                                    <c:if
                                                        test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </td>
                        <td>
                            <button type="button" class="btn btn-important" style="width: 50px;"
                                    onclick="javascript:goSearch();">조회
                            </button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색조건 -->
            <div class="title-wrap mt10">
                <div class="btn-group">
                    <h4>더존 코드 관리 리스트</h4>
                    <i class="material-iconserror font-16" style="vertical-align: middle;"
                       onmouseover="javascript:show9()" onmouseout="javascript:hide9()"></i>
                    <div class="text-warning mr5 ml5">
                        - 매년 1월에만 저장 가능, 과거 정보는 수정 불가
                    </div>
                    <div class="con-info" id="show9"
                         style="max-height: 500px; left: 22vh; width: 460px; display: none; top:10vh;">
                        <ul class="">
                            <li>
                                <span style="font-weight: bold">순서 이동 기능</span><br>
                                1. [No.] 가 순서입니다.</br>
                                2. 해당 [No.] 셀을 클릭하고 [행올림, 행내림] 버튼을 클릭하면 이동됩니다.
                            </li>
                        </ul>
                    </div>
                    <div class="right text-warning mr5">
                        최대 행 추가 수치 : <span id="maker_min"></span> / <span id="maker_max"></span>
                    </div>
                    <div>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                            <jsp:param name="pos" value="MID_R"/>
                        </jsp:include>
                    </div>
                </div>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>

            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong id="total_cnt" class="text-primary">0</strong>건
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>