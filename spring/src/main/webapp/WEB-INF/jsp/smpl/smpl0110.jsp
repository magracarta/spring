<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   <style type="text/css">
	   /* 리스트 템플릿에서 사용할 클래스 */
	   .myList-style {
	      text-align : left;
	      white-space : nowrap;
	   }
	   .myList-style .myList-col {
	      overflow: hidden;
	      text-overflow: ellipsis;
	      display:inline-block;
	   }
	   
	   </style>

	   <script type="text/javascript">

           //validation
           var auiGrid;
           var auiGridTest;
           var dataFieldName = [];

           //명언 칼럼 지정
           var columnAdvice = [
               {
                   headerText : "인명",
                   dataField : "author",
                   width : "250",
                   minWidth : "250",
                   style : "aui-center"
               },
               {
                   headerText : "별칭",
                   dataField : "authorProfile",
                   width : "250",
                   minWidth : "250",
                   style : "aui-center"
               },
               {
                   headerText : "명언",
                   dataField : "message",
                   width : "500",
                   minWidth : "500",
                   style : "aui-center"
               }
           ];

            // 대기
           $(document).ready(function() {
               //json data 통신
               fetchData();
               //grid 생성
               createAUIGrid();
               createAUIGridTest();
           });


           function fetchData() {
               fetch('https://korean-advice-open-api.vercel.app/api/advice')
                   .then(response => response.json())
                   .then(data => {
                       //AUIGrid는 Array-Object로 변환해줘야함
                       createAUIGridTest([data])
                       console.log('json 성공', data);
                   })
                   .catch(error => console.error('Error fetching data:', error));
           }


           function createAUIGrid() {
               var gridPros = {
                   // rowIdField 설정
                   rowIdField : "_$uid",
                   // rowNumber
                   showRowNumColumn: true,
                   editable : false,
                   headerHeight : 40,
                   noDataMessage: "출력할 데이터가 없습니다.",
               };
               var columnLayout = [
                   {
                       headerText : "부품번호",
                       dataField : "part_no",
                       width : "160",
                       minWidth : "160",
                       style : "aui-center"
                   },
                   {
                       headerText : "신번호",
                       dataField : "part_new_no",
                       headerStyle : "aui-fold",
                       width : "110",
                       minWidth : "110",
                       style : "aui-center"
                   },
                   {
                       headerText : "구번호",
                       dataField : "part_old_no",
                       headerStyle : "aui-fold",
                       width : "110",
                       minWidth : "110",
                       style : "aui-center",
                   },
                   {
                       headerText : "신번호호환",
                       dataField : "part_new_exchange_name",
                       headerStyle : "aui-fold",
                       width : "95",
                       minWidth : "95",
                       style : "aui-center"
                   },
                   {
                       headerText : "부품명",
                       dataField : "part_name",
                       style : "aui-left",
                       width : "300",
                       minWidth : "260",
                       styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                           if($M.getValue("part_detail_show_yn") == "Y") {
                               return "aui-popup";
                           }
                       },
                   },
                   {
                       headerText : "저장위치",
                       dataField : "storage_name",
                       width : "100",
                       minWidth : "100",
                       style : "aui-center"
                   },
                   {
                       headerText : "현재고",
                       dataField : "part_current",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "80",
                       minWidth : "70",
                       style : "aui-center aui-popup"
                   },
                   {
                       headerText : "부품구분",
                       dataField : "part_margin_cd",
                       width : "80",
                       minWidth : "70",
                       style : "aui-center	"
                   },
                   {
                       headerText : "가용재고",
                       dataField : "current_able_stock",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "80",
                       minWidth : "70",
                       style : "aui-center"
                   },
                   {
                       headerText : "입고단가",
                       dataField : "in_stock_price",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "95",
                       minWidth : "95",
                       style : "aui-right"
                   },
                   {
                       headerText : "VIP가<br>(VAT별도)",
                       dataField : "vip_sale_price",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "95",
                       minWidth : "95",
                       style : "aui-right"
                   },
                   {
                       headerText : "VIP가<br>(VAT포함)",
                       dataField : "vip_sale_vat_price",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "95",
                       minWidth : "95",
                       style : "aui-right"
                   },
                   {
                       headerText : "일반가<br>(VAT별도)",
                       dataField : "sale_price",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "95",
                       minWidth : "95",
                       style : "aui-right"
                   },
                   {
                       headerText : "당해판매",
                       dataField : "part_year",
                       headerStyle : "aui-fold",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "80",
                       minWidth : "80",
                       style : "aui-center"
                   },
                   {
                       headerText : "전년판매",
                       dataField : "part_before1",
                       headerStyle : "aui-fold",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "80",
                       minWidth : "80",
                       style : "aui-center"
                   },
                   {
                       headerText : "전전년판매",
                       dataField : "part_before2",
                       headerStyle : "aui-fold",
                       dataType : "numeric",
                       formatString : "#,##0",
                       width : "80",
                       minWidth : "80",
                       style : "aui-center"
                   },
                   {
                       headerText : "관리구분",
                       dataField : "part_mng_name",
                       width : "100",
                       minWidth : "100",
                       style : "aui-center",
                       renderer : {
                           type : "TemplateRenderer"
                       },
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						if(item["part_mng_name"] == "장기재고" || item["part_mng_name"] == "충당재고") {
// 							var template = '<div>' + '<span style="color:red";>' + item.part_mng_name + '</span>' + '</div>';
// 							return template;
// 						} else {
// 						   var template = '<div>' + '<span style="color:black";>' + item.part_mng_name + '</span>' + '</div>';
// 						   return template;
// 						}
// 					}
                   },
                   {
                       dataField : "aui_status_cd",
                       visible : false
                   }
               ]
               // 실제로 #grid_wrap 에 그리드 생성
               auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
               // 그리드 갱신
               AUIGrid.setGridData(auiGrid, []);
               AUIGrid.bind(auiGrid, "cellClick", function(event) {
                   // 부품명 셀 클릭 시 부품마스터상세 팝업 호출
                   var popupOption = "";
                   var param = {
                       "part_no" : event.item["part_no"]
                   };
                   if(event.dataField == 'part_name'){
                       if($M.getValue("part_detail_show_yn") == "Y") {
                           $M.goNextPage('/part/part0701p01', "part_no=" + param.part_no, {popupStatus : popupOption});
                       }
                       // 현재고 셀 클릭 시 부품재고상세 팝업 호출
                   }
                   if(event.dataField == 'part_current') {
                       $M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
                   };
               });
               AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

               // 펼치기 전에 접힐 컬럼 목록
               var auiColList = AUIGrid.getColumnInfoList(auiGrid);
               for (var i = 0; i <auiColList.length; ++i) {
                   if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                       dataFieldName.push(auiColList[i].dataField);
                   }
               }
               for (var i = 0; i < dataFieldName.length; ++i) {
                   var dataField = dataFieldName[i];
                   AUIGrid.hideColumnByDataField(auiGrid, dataField);
               }
           }


           //명언 api 조회에 나올 예제 그리드
           function  createAUIGridTest(exdata) {

               var gridProps2 = {
                   // rowIdField 설정
                   rowIdField : "_$uid",
                   showRowNumColumn: true,
                   editable : false,
                   headerHeight : 40,
                   noDataMessage: "출력할 데이터가 없습니다.", //이거 지금 안되고 있음
               };

               auiGridAdvice = AUIGrid.create("#auiGridAdvice", columnAdvice, gridProps2);
               AUIGrid.setGridData(auiGridAdvice, exdata);


           }


           // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
           function fnScollChangeHandelr(event) {
               if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                   //goMoreData();
               };
           }

           // **
           //상단 컨트롤바 유틸
           // **

           //조회
           function fnSearch(successFunc) {
               isLoading = true;
               var stock_date = '${inputParam.s_current_mon}';
               var param = {
                   "stock_date" : stock_date,
                   "s_part_no" : $M.getValue("s_part_no"),
                   "s_part_name" : $M.getValue("s_part_name"),
                   "s_part_mng_cd" : $M.getValue("s_part_mng_cd"),
                   "s_not_sale_yn" : $M.getValue("part_sale_stop_exclude_yn"),
                   "s_not_in_yn" : $M.getValue("part_no_income_exclude_yn"),
                   "page" : page,
                   "rows" : $M.getValue("s_rows")
               };
               $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
                   function(result){
                       isLoading = false;
                       if(result.success) {
                           successFunc(result);
                       };
                   }
               );
           }

           //숨김 칼럼 펼침
           function fnChangeColumn(event) {
               var data = AUIGrid.getGridData(auiGrid);
               var target = event.target || event.srcElement;
               if(!target)	return;

               var dataField = target.value;
               var checked = target.checked;

               for (var i = 0; i < dataFieldName.length; ++i) {
                   var dataField = dataFieldName[i];

                   if(checked) {
                       AUIGrid.showColumnByDataField(auiGrid, dataField);
                   } else {
                       AUIGrid.hideColumnByDataField(auiGrid, dataField);
                   }
               }
           }


       </script>
<%--    스크립트 종료--%>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
   <!-- 메인 타이틀 -->

   		  <div class="main-title" style="width:900px;">
	         <h2>예제용 게시판</h2>
         </div>
<%--          컨텐츠 시작--%>
         <div class="contents">
<%--          검색 및 조회 유틸--%>
             <div class="search-wrap">
                 <table class="table">
                     <colgroup>
                         <col width="60px">
                         <col width="130px">
                         <col width="60px">
                         <col width="130px">
                         <col width="70px">
                         <col width="130px">
                         <col width="100px">
                         <col width="160px">
                         <col width="65px">
                         <col width="160px">
                         <col width="*">
                     </colgroup>
                     <tbody>
                     <tr>
                         <th>부품번호</th>
                         <td>
                             <input type="text" class="form-control" id="s_part_no" name="s_part_no">
                         </td>
                         <th>부품명</th>
                         <td>
                             <input type="text" class="form-control" id="s_part_name" name="s_part_name">
                         </td>
                         <th>관리구분</th>
                         <td>
                             <select class="form-control" id="s_part_mng_cd" name="s_part_mng_cd">
                                 <option value="">- 전체 -</option>
                                 <c:forEach var="item" items="${codeMap['PART_MNG']}">
                                     <c:if test="${item.code_value ne '0' && item.code_value ne '9'}"><option value="${item.code_value}">${item.code_name}</option></c:if>
                                 </c:forEach>
                             </select>
                         </td>
                         <th class="text-right">매출정지 여부</th>
                         <td>
                             <div class="form-check form-check-inline">
                                 <input class="form-check-input" type="radio" id="s_not_sale_y" name="part_sale_stop_exclude_yn" value="Y" ${SecureUser.getPart_sale_stop_exclude_yn() eq 'Y' ? 'checked="checked"' : ''}>
                                 <label class="form-check-label" for="s_not_sale_y">제외</label>
                             </div>
                             <div class="form-check form-check-inline">
                                 <input class="form-check-input" type="radio" id="s_not_sale_n" name="part_sale_stop_exclude_yn" value="N" ${SecureUser.getPart_sale_stop_exclude_yn() eq 'N' ? 'checked="checked"' : ''}>
                                 <label class="form-check-label" for="s_not_sale_n">제외안함</label>
                             </div>
                         </td>
                         <th class="text-right">미수입 여부</th>
                         <td>
                             <div class="form-check form-check-inline">
                                 <input class="form-check-input" type="radio" id="s_not_in_y" name="part_no_income_exclude_yn" value="Y" ${SecureUser.getPart_no_income_exclude_yn() eq 'Y' ? 'checked="checked"' : ''}>
                                 <label class="form-check-label" for="s_not_in_y">제외</label>
                             </div>
                             <div class="form-check form-check-inline">
                                 <input class="form-check-input" type="radio" id="s_not_in_n" name="part_no_income_exclude_yn" value="N" ${SecureUser.getPart_no_income_exclude_yn() eq 'N' ? 'checked="checked"' : ''}>
                                 <label class="form-check-label" for="s_not_in_n">제외안함</label>
                             </div>
                         </td>
                         <td class="">
                             <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                         </td>
                     </tr>
                     </tbody>
                 </table>
             </div>
<%--          조회 결과--%>
             <div class="title-wrap mt10">
                 <h4>조회결과</h4>
                 <div class="btn-group">
                     <div class="right">
                         <div class="form-check form-check-inline">
                             <label for="s_toggle_column" style="color:black;">
                                 <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
                             </label>
                         </div>
                         <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                     </div>
                 </div>
             </div>
             <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
         </div>
<%--          명언 api 조회--%>
         <div class="main-title" style="width:900px;">
	         <h2>명언 api 조회</h2>
         </div>
         <div class="contents">
         	<div id="auiGridAdvice" style="width:auto; height:120px;"></div>
         </div>
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>